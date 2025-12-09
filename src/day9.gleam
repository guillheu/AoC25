import gleam/bool
import gleam/int
import gleam/io
import gleam/list
import gleam/order
import gleam/string
import gleeunit/should
import simplifile

const filename = "day9.txt"

// const min_coordinate = 0

// const max_coordinate = 10

const middle_coordinate = 50_000

type RedTile {
  RedTile(x: Int, y: Int)
}

type Rectangle {
  Rectangle(from: RedTile, to: RedTile, area: Int)
}

type Quadrant {
  TopRight
  BottomRight
  TopLeft
  BottomLeft
}

type QuadrantMaps {
  QuadrantMaps(
    top_right: List(RedTile),
    bottom_right: List(RedTile),
    top_left: List(RedTile),
    bottom_left: List(RedTile),
  )
}

type Edge(kind) {
  Edge(position: Int, start: Int, end: Int)
}

type Horizontal

type Vertical

type GreenShape {
  GreenShape(
    horizontal_edges: List(Edge(Horizontal)),
    vertical_edges: List(Edge(Vertical)),
  )
}

pub fn pb1() -> Int {
  let red_tiles =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(line_to_red_tile)

  let quadrant_maps = QuadrantMaps([], [], [], [])

  let quadrant_maps =
    list.fold(red_tiles, quadrant_maps, fn(quadrant_maps, next_tile) {
      let tile_quadrant = case next_tile.x, next_tile.y {
        x, y if x >= middle_coordinate && y >= middle_coordinate -> BottomRight
        x, y if x < middle_coordinate && y >= middle_coordinate -> BottomLeft
        x, y if x >= middle_coordinate && y < middle_coordinate -> TopRight
        x, y if x < middle_coordinate && y < middle_coordinate -> TopLeft
        x, y ->
          panic as {
            "??? x: " <> int.to_string(x) <> " y: " <> int.to_string(y)
          }
      }
      case tile_quadrant {
        BottomLeft ->
          QuadrantMaps(..quadrant_maps, bottom_left: [
            next_tile,
            ..quadrant_maps.bottom_left
          ])
        BottomRight ->
          QuadrantMaps(..quadrant_maps, bottom_right: [
            next_tile,
            ..quadrant_maps.bottom_right
          ])
        TopLeft ->
          QuadrantMaps(..quadrant_maps, top_left: [
            next_tile,
            ..quadrant_maps.top_left
          ])
        TopRight ->
          QuadrantMaps(..quadrant_maps, top_right: [
            next_tile,
            ..quadrant_maps.top_right
          ])
      }
    })
  let tr_bl_rectangles =
    quadrant_maps_to_rectangles(
      quadrant_maps.top_right,
      quadrant_maps.bottom_left,
    )
  let tl_br_rectangles =
    quadrant_maps_to_rectangles(
      quadrant_maps.top_left,
      quadrant_maps.bottom_right,
    )

  let rectangle_candidates =
    list.append(tl_br_rectangles, tr_bl_rectangles)
    |> list.sort(compare_rectangles_area)
    |> list.reverse

  let assert [largest_rectangle, ..rest] = rectangle_candidates
  largest_rectangle.area
}

pub fn pb2() -> Int {
  let red_tiles =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(line_to_red_tile)

  let green_shape = GreenShape([], [])
  let green_shape =
    list.window_by_2(red_tiles)
    |> list.prepend(#(
      red_tiles |> list.first |> should.be_ok,
      red_tiles |> list.reverse |> list.first |> should.be_ok,
    ))
    |> list.fold(green_shape, fn(green_shape, two_tiles) {
      let #(tile1, tile2) = two_tiles
      case tile1.x, tile2.x, tile1.y, tile2.y {
        x1, x2, y1, y2 if x1 == x2 ->
          GreenShape(..green_shape, vertical_edges: [
            Edge(x1, int.min(y1, y2), int.max(y1, y2)),
            ..green_shape.vertical_edges
          ])
        x1, x2, y1, y2 if y1 == y2 ->
          GreenShape(..green_shape, horizontal_edges: [
            Edge(y1, int.min(x1, x2), int.max(x1, x2)),
            ..green_shape.horizontal_edges
          ])
        x1, x2, y1, y2 ->
          panic as {
            "found non-orthogonal edge: x1: "
            <> int.to_string(x1)
            <> " ; x2: "
            <> int.to_string(x2)
            <> " ; y1: "
            <> int.to_string(y1)
            <> " ; y2: "
            <> int.to_string(y2)
          }
      }
    })
    |> sort_green_shape_edges

  let rectangle_candidates =
    list.combination_pairs(red_tiles)
    |> list.map(fn(tiles) {
      let #(tile1, tile2) = tiles
      tiles_to_rectangle(tile1, tile2)
    })
    |> list.sort(compare_rectangles_area)
    |> list.reverse

  let assert Ok(best_rectangle_that_fits) =
    list.find(rectangle_candidates, rectangle_fits_within_shape(green_shape, _))

  best_rectangle_that_fits.area
}

pub fn check_input_creates_self_intersecting_shape() -> Bool {
  let red_tiles =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.map(line_to_red_tile)

  let quadrant_maps = QuadrantMaps([], [], [], [])

  let quadrant_maps =
    list.fold(red_tiles, quadrant_maps, fn(quadrant_maps, next_tile) {
      let tile_quadrant = case next_tile.x, next_tile.y {
        x, y if x >= middle_coordinate && y >= middle_coordinate -> BottomRight
        x, y if x < middle_coordinate && y >= middle_coordinate -> BottomLeft
        x, y if x >= middle_coordinate && y < middle_coordinate -> TopRight
        x, y if x < middle_coordinate && y < middle_coordinate -> TopLeft
        x, y ->
          panic as {
            "??? x: " <> int.to_string(x) <> " y: " <> int.to_string(y)
          }
      }
      case tile_quadrant {
        BottomLeft ->
          QuadrantMaps(..quadrant_maps, bottom_left: [
            next_tile,
            ..quadrant_maps.bottom_left
          ])
        BottomRight ->
          QuadrantMaps(..quadrant_maps, bottom_right: [
            next_tile,
            ..quadrant_maps.bottom_right
          ])
        TopLeft ->
          QuadrantMaps(..quadrant_maps, top_left: [
            next_tile,
            ..quadrant_maps.top_left
          ])
        TopRight ->
          QuadrantMaps(..quadrant_maps, top_right: [
            next_tile,
            ..quadrant_maps.top_right
          ])
      }
    })

  let green_shape = GreenShape([], [])
  let green_shape =
    list.window_by_2(red_tiles)
    |> list.fold(green_shape, fn(green_shape, two_tiles) {
      let #(tile1, tile2) = two_tiles
      case tile1.x, tile2.x, tile1.y, tile2.y {
        x1, x2, y1, y2 if x1 == x2 ->
          GreenShape(..green_shape, vertical_edges: [
            Edge(x1, int.min(y1, y2), int.max(y1, y2)),
            ..green_shape.vertical_edges
          ])
        x1, x2, y1, y2 if y1 == y2 ->
          GreenShape(..green_shape, horizontal_edges: [
            Edge(y1, int.min(x1, x2), int.max(x1, x2)),
            ..green_shape.horizontal_edges
          ])
        x1, x2, y1, y2 ->
          panic as {
            "found non-orthogonal edge: x1: "
            <> int.to_string(x1)
            <> " ; x2: "
            <> int.to_string(x2)
            <> " ; y1: "
            <> int.to_string(y1)
            <> " ; y2: "
            <> int.to_string(y2)
          }
      }
    })
  is_shape_self_intersecting(green_shape)
}

fn sort_green_shape_edges(green_shape: GreenShape) -> GreenShape {
  let new_vertical_edges =
    list.sort(green_shape.vertical_edges, fn(edge1, edge2) {
      int.compare(edge1.position, edge2.position)
    })
  let new_horizontal_edges =
    list.sort(green_shape.horizontal_edges, fn(edge1, edge2) {
      int.compare(edge1.position, edge2.position)
    })
  GreenShape(
    vertical_edges: new_vertical_edges,
    horizontal_edges: new_horizontal_edges,
  )
}

fn is_shape_self_intersecting(green_shape: GreenShape) -> Bool {
  list.any(green_shape.horizontal_edges, fn(edge_h) {
    list.any(green_shape.vertical_edges, edges_intersect(_, edge_h))
  })
}

fn rectangle_fits_within_shape(
  green_shape: GreenShape,
  rectangle: Rectangle,
) -> Bool {
  let #(ht, vr, hb, vl) = compute_rectangle_edges(rectangle)

  //io.println("Next rectangle...")
  //io.println("")
  //io.println("")
  //io.println("Considering the following rectangle:")
  //io.println("X: " <> int.to_string(ht.start) <> " - " <> int.to_string(ht.end))
  //io.println("Y: " <> int.to_string(vl.start) <> " - " <> int.to_string(vl.end))
  //io.println("Area " <> rectangle.area |> int.to_string)

  let green_horizontal_edges_to_check =
    green_shape.horizontal_edges
    |> list.filter(edge_fits_within(_, vr.start, vr.end))

  let green_vertical_edges_to_check =
    green_shape.vertical_edges
    |> list.filter(edge_fits_within(_, ht.start, ht.end))

  //io.println("")

  //io.println(
  //     "Checking "
  //     <> int.to_string(list.length(green_vertical_edges_to_check))
  //     <> " vertical edges",
  //   )

  let a_vertical_edge_crosses_rectangle =
    list.any(
      green_vertical_edges_to_check,
      fn(green_vertical_edge_within_range) {
        //io.println("")
        //io.println(
        //   "Considering vertical edge: X="
        //   <> int.to_string(green_vertical_edge_within_range.position)
        //   <> ", Y: "
        //   <> int.to_string(green_vertical_edge_within_range.start)
        //   <> " - "
        //   <> int.to_string(green_vertical_edge_within_range.end),
        // )
        let r =
          green_vertical_edge_within_range.end > { ht.position }
          && green_vertical_edge_within_range.start < { hb.position }
        // case r {
        //   False -> //io.println("Does not cross")
        //   True -> //io.println("Crossing!!!")
        // }
        r
      },
    )
  use <- bool.guard(a_vertical_edge_crosses_rectangle, False)

  //io.println(
  //     "Checking "
  //     <> int.to_string(list.length(green_horizontal_edges_to_check))
  //     <> " horizontal edges",
  //   )

  !list.any(
    green_horizontal_edges_to_check,
    fn(green_horizontal_edge_within_range) {
      //io.println(
      //     "Considering horizontal edge: Y="
      //     <> int.to_string(green_horizontal_edge_within_range.position)
      //     <> ", X: "
      //     <> int.to_string(green_horizontal_edge_within_range.start)
      //     <> " - "
      //     <> int.to_string(green_horizontal_edge_within_range.end),
      //   )
      green_horizontal_edge_within_range.end > vl.position
      && green_horizontal_edge_within_range.start < vr.position
    },
  )
}

fn edge_fits_within(edge: Edge(any), from: Int, to: Int) -> Bool {
  edge.position > from && edge.position < to
}

fn compute_rectangle_edges(
  from: Rectangle,
) -> #(Edge(Horizontal), Edge(Vertical), Edge(Horizontal), Edge(Vertical)) {
  let x_min = int.min(from.from.x, from.to.x)
  let x_max = int.max(from.from.x, from.to.x)
  let y_min = int.min(from.from.y, from.to.y)
  let y_max = int.max(from.from.y, from.to.y)

  let ht = Edge(y_min, x_min, x_max)
  let vr = Edge(x_max, y_min, y_max)
  let hb = Edge(y_max, x_min, x_max)
  let vl = Edge(x_min, y_min, y_max)

  #(ht, vr, hb, vl)
}

fn edges_intersect(edge_v: Edge(Vertical), edge_h: Edge(Horizontal)) -> Bool {
  edge_h.start <= edge_v.position
  && edge_v.position <= edge_h.end
  && edge_v.start <= edge_h.position
  && edge_h.position <= edge_v.end
}

fn line_to_red_tile(line: String) -> RedTile {
  let assert Ok(#(x_string, y_string)) = string.split_once(line, ",")
  let assert Ok(x) = int.parse(x_string)
  let assert Ok(y) = int.parse(y_string)
  RedTile(x, y)
}

fn quadrant_maps_to_rectangles(
  quadrant1: List(RedTile),
  quadrant2: List(RedTile),
) -> List(Rectangle) {
  list.fold(quadrant1, [], fn(acc, next_q1_tile) {
    list.fold(quadrant2, acc, fn(acc, next_q2_tile) {
      [tiles_to_rectangle(next_q1_tile, next_q2_tile), ..acc]
    })
  })
}

fn tiles_to_rectangle(tile1: RedTile, tile2: RedTile) -> Rectangle {
  Rectangle(
    tile1,
    tile2,
    { int.absolute_value(tile1.x - tile2.x) + 1 }
      * { int.absolute_value(tile1.y - tile2.y) + 1 },
  )
}

fn compare_rectangles_area(r1: Rectangle, r2: Rectangle) -> order.Order {
  int.compare(r1.area, r2.area)
}
