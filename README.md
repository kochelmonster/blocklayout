# blocklayout

A html preprocessor to transform a simple block graphic into a flex grid.

## Example

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
<div style="height: 20em; width: 20em; display: grid;">
<div style="background: blue; grid-column-start: 1; grid-column-end: 3; grid-row-start: 1; grid-row-end: 2;"></div>
<div style="background: green; grid-column-start: 3; grid-column-end: 4; grid-row-start: 1; grid-row-end: 3;"></div>
<div style="background: red; grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 4;"></div>
<div style="background: grey; grid-column-start: 2; grid-column-end: 3; grid-row-start: 2; grid-row-end: 3;"></div>
<div style="background: yellow; grid-column-start: 2; grid-column-end: 4; grid-row-start: 3; grid-row-end: 4;"></div>
</div>
```

and this is the result

<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <foreignObject width="200" height="200">
<div style="height: 20em; width: 20em; display: grid;"><div style="background: blue; grid-column-start: 1; grid-column-end: 3; grid-row-start: 1; grid-row-end: 2;"></div><div style="background: green; grid-column-start: 3; grid-column-end: 4; grid-row-start: 1; grid-row-end: 3;"></div><div style="background: red; grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 4;"></div><div style="background: grey; grid-column-start: 2; grid-column-end: 3; grid-row-start: 2; grid-row-end: 3;"></div><div style="background: yellow; grid-column-start: 2; grid-column-end: 4; grid-row-start: 3; grid-row-end: 4;"></div></div>    
  </foreignObject>
</svg>

## Usage

Install with

```bash
npm install blocklayout --save-dev
```

To run the preprocessor call

```bash
npx blocklayout foo.html > processed.html
```

For svelte there is a preprocessor plugin for `svelte.config.js`

```javascript
import adapter from '@sveltejs/adapter-auto';
import blocklayout from "blocklayout/svelte";

/** @type {import('@sveltejs/kit').Config} */
const config = {
  kit: {
    adapter: adapter()
  },
  preprocess: [
    blocklayout(),
  ],
};

export default config;
```

## Documentation

A grid layout is defined by the attribute `data-grid`, the content of the flex grid cells is defined by the attribute `data-field`. 
The design is fairly simple: columns are separated by a `|` and rows are separated by a new line.
If a cell shall be spanned over multiple rows use `"`.

### Alignment

You can align cells to the grid by adding a specification in curly brackets `{}`.

```html
<div data-grid style="height: 20em; width: 20em; border: 1px solid black">
top-left{tl}   |top-center{tc}   |top-right{tr}
middle-left{ml}|middle-center{mc}|middle-right{mr}
bottom-left{bl}|bottom-center{bc}|bottom-right{br}
</div>
```

<div style="height: 20em; width: 20em; border: 1px solid black; display: grid;"><div style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 1; grid-row-end: 2; justify-self: start; align-self: start;">top-left</div><label style="grid-column-start: 2; grid-column-end: 3; grid-row-start: 1; grid-row-end: 2; justify-self: center; align-self: start;">top-center</label><label style="grid-column-start: 3; grid-column-end: 4; grid-row-start: 1; grid-row-end: 2; justify-self: end; align-self: start;">top-right</label><label style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 3; justify-self: start; align-self: center;">middle-left</label><label style="grid-column-start: 2; grid-column-end: 3; grid-row-start: 2; grid-row-end: 3; justify-self: center; align-self: center;">middle-center</label><label style="grid-column-start: 3; grid-column-end: 4; grid-row-start: 2; grid-row-end: 3; justify-self: end; align-self: center;">middle-right</label><label style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 3; grid-row-end: 4; justify-self: start; align-self: end;">bottom-left</label><label style="grid-column-start: 2; grid-column-end: 3; grid-row-start: 3; grid-row-end: 4; justify-self: center; align-self: end;">bottom-center</label><label style="grid-column-start: 3; grid-column-end: 4; grid-row-start: 3; grid-row-end: 4; justify-self: end; align-self: end;">bottom-right</label></div>

|Alignment Char | Effect                     |
|----           | ----                       |
|l              | cell is aligned to the left|
|c              | cell is aligned in the center |
|r              | cell is aligned to right |
|j              | cell is horizontally stretched|
|t              | cell is aligned to the top|
|m              | cell is aligned in the middle |
|b              | cell is aligned to bottom |
|e              | cell is vertically stretched|

### Stretchers

You can define which columns or rows should be stretched by including the stretch factor at the last column/row in straight brackets `[]`.

```html
<div data-grid style="height: 10em; width: 20em; border: 1px solid black">
column-stretched |column-fixed|
column-spanned                |
row-fixed        |row-spanned |
row-stretched    |   "        |[1]
[1]              |
</div>
```

<div style="height: 10em; width: 20em; border: 1px solid black; grid-template-columns: 1fr auto; grid-template-rows: auto auto auto 1fr; display: grid;"><div style="background: green; grid-column-start: 1; grid-column-end: 2; grid-row-start: 1; grid-row-end: 2;">column-stretched</div><div style="background: yellow; grid-column-start: 2; grid-column-end: 3; grid-row-start: 1; grid-row-end: 2;">column-fixed</div><div style="background: grey; grid-column-start: 1; grid-column-end: 3; grid-row-start: 2; grid-row-end: 3;">column-spanned</div><div style="background: orange; grid-column-start: 1; grid-column-end: 2; grid-row-start: 3; grid-row-end: 4;">row-fixed</div><div style="background: orangered; grid-column-start: 2; grid-column-end: 3; grid-row-start: 3; grid-row-end: 5;">row-spanned</div><div style="background: blue; grid-column-start: 1; grid-column-end: 2; grid-row-start: 4; grid-row-end: 5;">row-stretched</div></div>


### Tabindex

You can define the tab order of the cells by adding a number in curly brackets `{}`

```html
<div data-grid="10">
one{1}  |sub{4}
two{2}  | "
three{3}| "
</div>
<a data-field="one" tabindex="1">one</a>
<a data-field="two" tabindex="1">two</a>
<a data-field="three" tabindex="1">three</a>
<div data-grid data-field="sub">
five{2}
four{1}
six{3}
</div>
<a data-field="four" tabindex="1">four</a>
<a data-field="five" tabindex="1">five</a>
<a data-field="six" tabindex="1">six</a>
```
Results in

```html
<div style="display: grid;">
  <a tabindex="10" style="...">one</a>
  <div style="display: grid; ...">
    <a tabindex="14" style="...">five</a>
    <a tabindex="13" style="...">four</a>
    <a tabindex="15" style="...">six</a>
  </div>
  <a tabindex="11" style="...">two</a>
  <a tabindex="12" style="...">three</a>
</div>
```

<div style="display: grid;border: 1px solid black;"><a tabindex="10" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 1; grid-row-end: 2;">one</a><div style="display: grid; grid-column-start: 2; grid-column-end: 3; grid-row-start: 1; grid-row-end: 4;"><a tabindex="14" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 1; grid-row-end: 2;">five</a><a tabindex="13" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 3;">four</a><a tabindex="15" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 3; grid-row-end: 4;">six</a></div><a tabindex="11" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 2; grid-row-end: 3;">two</a><a tabindex="12" style="grid-column-start: 1; grid-column-end: 2; grid-row-start: 3; grid-row-end: 4;">three</a></div>

- blocklayout cares for tabindexes of sub designs
- blocklayout will only modify elements with an tabindex >= 0
- you can specify the starting tabindex by setting the `data-grid` attribute to a number.
- if there is an alignment specification the tabindex **must** be after the alignment.
