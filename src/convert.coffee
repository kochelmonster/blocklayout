import { JSDOM,  } from "jsdom"
import { layout_grid, create_element, grid_attrib, field_attrib } from "./layouter.js"

class FieldBlock
    constructor: (@block) ->

    render: (fields) ->
        result = create_element(@block.outerHTML)
        result.removeAttribute(field_attrib)
        return result.outerHTML


hierachy_level = (element) ->
    level = 0
    while element
        level++
        element = element.parentElement
    return level


inside_field = (element) ->
    element = element.parentElement
    while element
        return true if element.hasAttribute("data-field")
        element = element.parentElement
    return false


export convert = (source) ->
    locations = []
    dom = new JSDOM(source, {includeNodeLocations: true})
    element = dom.window.document
    grids = element.querySelectorAll("[#{grid_attrib}]")
    if not grids.length
        return
            converted: false
            result: source

    sorted_grids = []
    for g in grids
        g.layouter = layout_grid(g)
        sorted_grids.push([hierachy_level(g), g])

    divs = element.querySelectorAll("[#{field_attrib}]")
    fields = {}
    for f in divs
        if not f.getAttribute(grid_attrib)?
            f.layouter = new FieldBlock(f)

        if inside_field(f)
            f.remove()
        else
            # the field is already removed
            locations.push
                location: dom.nodeLocation(f)
                replace: ""

        fields[f.getAttribute(field_attrib)] = f

    sorted_grids.sort((a, b)->b[0]-a[0])
    for [_, g] in sorted_grids
        if not g.getAttribute(field_attrib)?
            result = g.layouter.render(fields, parseInt(g.tabindex or 1))

            if inside_field(g)
                # updates the node of the field
                g.replaceWith(create_element(result))
            else
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


