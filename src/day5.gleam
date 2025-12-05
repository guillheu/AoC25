import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order
import gleam/result
import gleam/set
import gleam/string
import gleeunit/should
import simplifile

const filename = "day5.txt"

type Range {
  Range(from: Int, to: Int)
}

pub fn pb2() -> Int {
  let assert Ok(#(ranges_string, _available_string)) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split_once("\n\n")

  let ranges =
    string.split(ranges_string, "\n")
    |> list.map(line_to_range)
    |> list.sort(compare_range_averages)
    |> list.fold([], fn(acc, next_range) {
      case acc {
        [] -> [next_range]
        [first, ..rest] ->
          case merge_nearby_ranges(first, next_range) {
            None -> [next_range, first, ..rest]
            Some(merged_range) -> [merged_range, ..rest]
          }
      }
    })

  // ranges
  // |>list.window_by_2
  // |>list.each(fn(window){
  //     let #(previous_range, next_range) = window
  //     assert previous_range.
  // })

  ranges
  |> list.map(range_size)
  |> list.reduce(int.add)
  |> should.be_ok
}

pub fn pb1() -> Int {
  let assert Ok(#(ranges_string, available_string)) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split_once("\n\n")

  let ranges =
    string.split(ranges_string, "\n")
    |> list.map(line_to_range)

  let available =
    string.split(available_string, "\n")
    |> list.map(int.parse)
    |> result.all
    |> should.be_ok

  list.count(available, fn(item) {
    list.any(ranges, item_is_within_range(item, _))
  })
}

fn merge_nearby_ranges(
  smaller_avg_range: Range,
  larger_avg_range: Range,
) -> Option(Range) {
  case smaller_avg_range.to >= larger_avg_range.from {
    False -> None
    True ->
      Range(
        int.min(smaller_avg_range.from, larger_avg_range.from),
        int.max(smaller_avg_range.to, larger_avg_range.to),
      )
      |> Some
  }
}

fn range_size(range: Range) -> Int {
  range.to - range.from + 1
}

fn line_to_range(from: String) -> Range {
  let assert Ok(#(start_string, finish_string)) = string.split_once(from, "-")
  let assert Ok(start) = int.parse(start_string)
  let assert Ok(finish) = int.parse(finish_string)
  Range(start, finish)
}

fn compare_range_averages(compare: Range, with: Range) -> order.Order {
  int.compare({ compare.to + compare.from } / 2, { with.to + with.from } / 2)
}

fn item_is_within_range(item: Int, range: Range) -> Bool {
  item <= range.to && item >= range.from
}
