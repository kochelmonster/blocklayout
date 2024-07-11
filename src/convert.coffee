import { JSDOM,  } from "jsdom"
import { layout_grid, create_element } from "./layouter.js"

grid_attrib = "data-grid"
field_attrib = "data-field"


class FieldBlock
    constructor: (@block) ->

    render: (fields) ->
        result = create_element(@block.outerHTML)
        result.removeAttribute(field_attrib)
        return result.outerHTML


export convert = (source) ->
    locations = []
    dom = new JSDOM(source, {includeNodeLocations: true})
    element = dom.window.document
    grids = element.querySelectorAll("[#{grid_attrib}]")
    if not grids.length
        return
            converted: false
            result: source

    for g in grids
        g.layouter = layout_grid(g)

    divs = element.querySelectorAll("[#{field_attrib}]")
    fields = {}
    for f in divs
        if not f.getAttribute(grid_attrib)?
            f.layouter = new FieldBlock(f)

        locations.push
            location: dom.nodeLocation(f)
            replace: ""
        fields[f.getAttribute(field_attrib)] = f

    for g in grids
        if not g.getAttribute(field_attrib)?
            result = g.layouter.render(fields, parseInt(g.tabindex or 1))
            locations.push
                location: dom.nodeLocation(g)
                replace: create_element(result).outerHTML

    # change the source from back
    locations.sort (a, b) ->
        b.location.startOffset - a.location.startOffset

    for l in locations
        source = source.slice(0, l.location.startOffset) \
            + l.replace + source.slice(l.location.endOffset+1)

    return
        converted: true
        result: source


