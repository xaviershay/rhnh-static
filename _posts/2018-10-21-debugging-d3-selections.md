---
title: "Using Size to Debug D3 Selections"
tags: ['code', 'javascript', 'd3']
date: 2018-10-21
layout: 'post'
---

Yesterday I was learning about the relatively new [General Update
Pattern](https://bl.ocks.org/mbostock/3808218) in D3, but I couldn't get it
working. I knew I was missing something obvious, but how to figure out what?

Because I was dealing with nested attributes, I was assigning the selections
to variables and then merging them later, so ended up with this heavily
simplified (and broken) code to display a list of tiles:

``` javascript
let tiles = container.selectAll('.tile').data(data, d => d.id)

let tilesEnter = tiles.enter()
  .append('div')
    .attr("class", "tiles")

tiles.select('.tile').merge(tilesEnter)
  .attr('color', d => d.color)

let contentEnter = tilesEnter
  .append('span')
    .attr('class', 'content')

tiles.select('.content').merge(contentEnter)
  html(d => d.content)
```

When I updated the data, the content of the tile in the child element updated,
but the color at the root level did not!

I tried a number of debugging approaches, but the one that I found easiest to
wrap my head around, and that eventually led me to a solution, was using the
[`size()`](https://github.com/d3/d3-selection#selection_size) to verify how
many elements where in each selection.

``` javascript
console.log("tiles entering", tilesEnter.size())
console.log("tiles updating", tiles.select('.tile').size())
console.log("content entering", contentEnter.size())
console.log("content updating", tiles.select('.content').size())
```

This allowed me to verify that for the second working case (for data with
four elements) that the enter/update selections went from 4 and 0
respectively to 0 and 4 when data was updated. For the first case, the update
selection was always zero, and this led me to notice the extra
`select('.tile')` shouldn't be there for the root case, since we're already
on that selection from the `selectAll` in the initial setup!

I found logging the entire selection to not be as useful, because it's
confusing what its internal state actually means.
