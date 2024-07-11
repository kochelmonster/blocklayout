import { JSDOM } from "jsdom"

jsdom = new JSDOM("")

export create_element = (html) ->
    jsdom.window.document.body.innerHTML = html
    return jsdom.window.document.body.firstChild


class Cell
    # base class of all parse cells.

    columns: [0, 0]
    ### the columns the cells span,
    columns = (2, 4) means the cell is in column 2, 3, 4
    ###

    rows: [0, 0]
    # the rows the cells span

    name: ""
    # the unique name of the cell

    __bool__ : () ->
        # if return False Cell will not be assigned (see Parser)
        return false

    set_rows: (rows) ->
        self.rows = rows


class DOMCell extends Cell
    # A cell rendering an html cell, must be mixed in with a DIVCell Mixin.

    at_top: false
    at_left: false
    at_right: false
    at_bottom: false
    # is the cell at border?

    __bool__: () -> true

    extend_dom: (element) ->
        style = element.style
        style.gridColumnStart = @columns[0]+1
        style.gridColumnEnd = @columns[1]+1
        style.gridRowStart = @rows[0]+1
        style.gridRowEnd = @rows[1]+2

        ###
        classes = element.classList
        classes.add("at-top") if @at_top
        classes.add("at-left") if @at_left
        classes.add("at-right") if @at_right
        classes.add("at-bottom") if @at_bottom
        ###


class Empty extends Cell
    @create: (cell_string) ->
        return new Empty() if not cell_string.trim()


class Stretcher extends Cell
    REGEXP: /\[(?<stretch>\d+)(?<moving>M*)?\]/
    stretch: 0
    # stretch factor

    moving: false

    constructor: (fields) ->
        super()
        @stretch = parseFloat(fields.stretch)
        @moving = true if fields.moving

    @create: (cell_string) ->
        mo = Stretcher.prototype.REGEXP.exec(cell_string.trim())
        return new Stretcher(mo.groups) if mo


class RowSpan extends Cell
    REGEXP: /\"/

    __bool__: () -> false

    @create: (cell_string) ->
        mo = RowSpan.prototype.REGEXP.exec(cell_string.trim())
        return new RowSpan() if mo


class AlignedCell extends DOMCell
    REGEXP: /(\{(?<align>[lcrj]?[tmbse]?)\})?/

    alignment: ''
    # cells alignment

    constructor: (fields) ->
        super()
        @alignment = fields.align if fields.align

    extend_dom: (element) ->
        super.extend_dom(element)

        style = element.style
        if @alignment.indexOf("l") >= 0
            style.justifySelf = "start"
        else if @alignment.indexOf("c") >= 0
            style.justifySelf = "center"
        else if @alignment.indexOf("r") >= 0
            style.justifySelf = "end"
        else if @alignment.indexOf("j") >= 0
            style.justifySelf = "stretch"

        if @alignment.indexOf("t") >= 0
            style.alignSelf = "start"
        else if @alignment.indexOf("m") >= 0
            style.alignSelf = "center"
        else if @alignment.indexOf("b") >= 0
            style.alignSelf = "end"
        else if @alignment.indexOf("e") >= 0
            style.alignSelf = "stretch"


class Field extends AlignedCell
    REGEXP: new RegExp(
        "(?<field>([^\\d\\W][ \\w]*))"        \ # field
        + AlignedCell.prototype.REGEXP.source \ # alignment
        + "(\\{(?<tabindex>\\d+)\\})?"        \ # tabindex
        + "([*]?)")                             # autofocus

    constructor: (fields) ->
        super(fields)
        @field = fields.field
        @tabindex = fields.tabindex

    render: (fields) ->
        field = fields[@field]
        if field
            content = create_element(field.layouter.render(fields))
        else
            content = create_element("<label>#{@field}</label>")

        @extend_dom(content)
        return content

    @create: (cell_string) ->
        mo = Field.prototype.REGEXP.exec(cell_string.trim())
        return new Field(mo.groups) if mo



class Parser
    ###The base class for a layout description parser, it provides functions
    for parsing cells in columns and rows.###

    STRETCHER: Stretcher

    CELL_TYPES: []
    # A list of possible cells types.

    row_stretchers: []
    # A sequence of row stretch factors.

    column_stretchers: []
    # A sequence of column stretch factors.

    row_splitters: []
    # A sequence of interactive row edges.

    column_splitters: []
    # A sequence of interactive column edges."""

    constructor: (@design) ->
        desc = @design.textContent.split("\n")
        while desc.length and desc[0].trim().length == 0
            desc.shift() 

        while desc.length
            last = desc.pop()
            if last.trim().length != 0
                desc.push(last)
                break

        desc = desc.join("\n")
        [columns, rows] = @parse_cells(desc)
        rows = @assign_columns(columns, rows)
        @assign_rows(rows)
        if @make_stretchers(rows)
            @assign_rows(rows)  # stretcher could change  rowspans

        for r, i in rows
            tmp = ([parseInt(k), v] for k, v of r when v.__bool__())
            tmp.sort((a, b) -> a[0]-b[0])
            rows[i] = (v for [k, v] in tmp)

        @rows = rows
        @assign_borders()

    render: (fields) ->
        result = create_element(@design.outerHTML)
        result.removeAttribute("grid")
        result.removeAttribute("field")

        if @column_stretchers.length
            cs = ((if c then "#{c}fr" else "auto") for c in @column_stretchers)
            result.style.gridTemplateColumns = cs.join(" ")

        if @row_stretchers.length
            rs = ((if r then "#{r}fr" else "auto") for r in @row_stretchers)
            result.style.gridTemplateRows = rs.join(" ")

        result.innerHTML = ""
        result.style.display = "grid"

        tabs = []
        for row in @rows
            for r in row
                element = r.render(fields)
                if r.tabindex 
                    children = element.querySelectorAll("[tabindex]")
                    tab_children = ([parseInt(c.getAttribute("tabindex") or 1), c] for c in children)
                    
                    # add the element if nececessary
                    ti = element.getAttribute("tabindex")
                    tab_children.push([parseInt(ti), element]) if ti?
                    tab_children = (tc for tc in tab_children when tc[0] >= 0)
                    
                    tab_children.sort((a, b)->a[0]-b[0])
                    tabs.push
                        base: parseInt(r.tabindex)
                        children: tab_children
                result.append(element)

        if tabs.length
            tabindex = 1
            tabs.sort((a, b)->a.base-b.base)
            for container in tabs
                for [_, el] in container.children
                    el.setAttribute("tabindex", tabindex++)
        
        return result.outerHTML

    parse_cells: (layout_string) ->
        cell_rows = []
        columns = {}
        rows = (r for r in layout_string.split("\n") when r.trim())
        max_row_len = Math.max.apply(null, rows.map((row) -> row.length))
        for r in rows
            r = r.padEnd(max_row_len)
            string_cells = r.split('|')
            cells = []
            start = 0
            for c in string_cells
                columns[start - 1] = true 
                end = start + c.length
                cells.push(@parse_cell(c.trim(), [start, end]))
                start = end + 1

            cell_rows.push(cells)

        return [columns, cell_rows]

    parse_cell: (cell_string, columns) ->
        for ct in @CELL_TYPES
            new_cell = ct.create(cell_string)
            if new_cell
                new_cell.columns = columns
                return new_cell

        throw "Cannot parse cell \"#{cell_string}\""

    # assigns column indices to the cells
    assign_columns: (columns, rows) ->
       # assign the cells to the columns
        columns[10000] = true
        columns = (parseInt(k) for k of columns)
        columns.sort((a, b)->a-b)
        @column_count = columns.length - 1

        for cells in rows
            for c in cells
                start = columns.findIndex((val)->val == c.columns[0]-1)
                end = columns.findIndex((val)->val == c.columns[1])
                end = @column_count if end < 0
                c.columns = [start, end]
        
        @row_count = rows.length
        result = []
        for r in rows
            cells = {}
            for c in r
                cells[c.columns[0]] = c
            result.push(cells)
        return result

    # assigns rows indices to the cells.
    assign_rows: (rows) ->
        for cells, r in rows
            for _, c of cells
                c.rows = [r, r]

        row_spans = {}
        rows.reverse()
        for cells in rows
            for col, rs of row_spans
                c = cells[col]
                throw "wrong row span (#{rs.columns[0]}, #{rs.rows[0]})" if not c
                c.rows = [c.rows[0], rs.rows[1]]

            row_spans = {}
            for col, c of cells
                row_spans[col] = c if c instanceof RowSpan
        rows.reverse()
        return

    is_stretcher: (cell) ->
        return cell instanceof Stretcher or cell instanceof Empty

    make_stretchers: (rows) ->
        last_col = @column_count - 1

        # check for column stretchers (in last row)
        last_row = rows[rows.length-1]
        tmp = tmp_count = 0
        for _, c of last_row
            tmp += @is_stretcher(c)
            tmp_count++
        is_last_row_stretcher = tmp == tmp_count

        if is_last_row_stretcher
            column_stretchers = (c for _, c of last_row when c instanceof Stretcher)
            rows.pop()
        else
            column_stretchers = []

        @row_count = rows.length

        # check for row stretchers
        row_stretchers = (r[last_col] for r in rows)
        row_stretchers = (s for s in row_stretchers when s instanceof Stretcher)

        if row_stretchers.length
            pos = (s) -> s.rows[0]
            @row_stretchers = @build_stretcher(row_stretchers, @row_count, pos)
            @row_splitters = @build_splitter(row_stretchers, @row_count, pos)

            # remove the stretcher columns
            @column_count--
            for r in rows
                if r[last_col]
                    delete r[last_col]
                    continue

                # the last column ist spanned!
                for _, c of r
                    c.columns = [c.columns[0], Math.min(c.columns[1], last_col - 1)]

        if column_stretchers.length
            pos = (s) -> s.columns[0]
            @column_stretchers = @build_stretcher(column_stretchers, @column_count, pos)
            @column_splitters = @build_splitter(column_stretchers, @column_count, pos)
            return true

        return false

    build_stretcher: (stretchers, size, pos) ->
        result = []
        for i in [0...size]
            result.push(0)

        for s in stretchers
            result[pos(s)] = s.stretch
        return result

    ### returns the moving edges, this must be two consecutive
    moving stretchers. 1 means the edge between row 0 and row 1###
    build_splitter: (stretchers, size, pos) ->
        result = []
        for i in [0...size]
            result.push(false)

        for s in stretchers
            result[pos(s)] = s.moving
        
        return (i+1 for m, i in result when m and result[i+1])

    # determines which cells are at the border.
    assign_borders: () ->
        right_col = @column_count - 1
        bottom_row = @row_count - 1
        for r in @rows
            for c in r
                c.at_left = c.columns[0] == 0
                c.at_right = c.columns[1] == right_col
                c.at_top = c.rows[0] == 0
                c.at_bottom = c.rows[1] == bottom_row
        return

class GridParser extends Parser
    CELL_TYPES: [Empty, Stretcher, Field, RowSpan]


export layout_grid = (block) ->
    return new GridParser(block)