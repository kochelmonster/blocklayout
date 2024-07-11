# blocklayout

A html preprocessor to transform a simple block graphic into a flex grid.

## example

You write this

```html
<div data-grid style="height:20em; width:20em">
blue         | green|
red  |grey   |  "   |
 "   |yellow        |
</div>
<div data-field="blue" style="background: blue;"></div>
<div data-field="green" style="background: green"></div>
<div data-field="red" style="background:red"></div>
<div data-field="yellow" style="background:yellow"></div>
<div data-field="grey" style="background:grey"></div>
```

blocklayout transforms it to this

```html
<div data-grid="" style="height: 20em; width: 20em; display: grid;">
<div style="background: blue; grid-column-start: 1; grid-column-end: 3; grid-row-start: 1; grid-row-end: 2;"></div>
<div style="background: green; grid-column-start: 3; grid-column-end: 4; grid-row-start: 1; grid-row-end: 3;"></div>
<div style="background: red; grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 4;"></div>
<div style="background: grey; grid-column-start: 2; grid-column-end: 3; grid-row-start: 2; grid-row-end: 3;"></div>
<div style="background: yellow; grid-column-start: 2; grid-column-end: 4; grid-row-start: 3; grid-row-end: 4;"></div>
</div>
```

