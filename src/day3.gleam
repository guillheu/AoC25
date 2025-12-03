import gleam/bool
import gleam/float
import gleam/int
import gleam/list
import gleam/order
import gleam/result
import gleam/string
import gleeunit/should
import simplifile

const filename = "day3.txt"

pub fn pb1() -> Int {
  simplifile.read(filename)
  |> should.be_ok
  |> string.split("\n")
  |> list.map(pb1_figure_out_batteries_to_turn_on(_, 2))
  |> list.fold(0, int.add)
}

pub fn pb2() -> Int {
  simplifile.read(filename)
  |> should.be_ok
  |> string.split("\n")
  |> list.map(pb1_figure_out_batteries_to_turn_on(_, 12))
  |> list.fold(0, int.add)
}

fn pb1_figure_out_batteries_to_turn_on(
  line: String,
  how_many_batteries: Int,
) -> Int {
  let batteries =
    string.to_graphemes(line)
    |> list.map(int.parse)
    |> result.all
    |> should.be_ok

  let #(_, first_batteries_are_the_ones_to_use) =
    list.range(how_many_batteries - 1, 0)
    |> list.fold(#(batteries, [[]]), fn(acc, end_digits_to_ignore) {
      let #(current_batteries, acc_list_of_lists) = acc
      let next_top_digit_is_the_biggest_in_this_list =
        recurse_scan_bank_for_largest_first_digit(
          current_batteries,
          [],
          end_digits_to_ignore,
        )
      let remaining_batteries =
        next_top_digit_is_the_biggest_in_this_list |> list.drop(1)
      #(remaining_batteries, [
        next_top_digit_is_the_biggest_in_this_list,
        ..acc_list_of_lists
      ])
    })

  first_batteries_are_the_ones_to_use
  |> list.reverse
  |> list.drop(1)
  |> list.map(list.first)
  |> result.all
  |> should.be_ok
  |> list.index_fold(0, fn(acc, current_digit, index) {
    int.power(10, { how_many_batteries - index - 1 } |> int.to_float)
    |> should.be_ok
    |> float.truncate
    |> int.multiply(current_digit)
    |> int.add(acc)
  })
}

fn recurse_scan_bank_for_largest_first_digit(
  remaining_batteries: List(Int),
  current_largest_and_following: List(Int),
  trailing_batteries_to_ignore: Int,
) -> List(Int) {
  use <- bool.guard(
    list.length(remaining_batteries) <= trailing_batteries_to_ignore,
    current_largest_and_following,
  )
  case remaining_batteries, current_largest_and_following {
    [_current, ..rest], [] ->
      recurse_scan_bank_for_largest_first_digit(
        rest,
        remaining_batteries,
        trailing_batteries_to_ignore,
      )
    [current, ..rest], [acc_largest, ..] ->
      case current <= acc_largest {
        True ->
          recurse_scan_bank_for_largest_first_digit(
            rest,
            current_largest_and_following,
            trailing_batteries_to_ignore,
          )
        False ->
          recurse_scan_bank_for_largest_first_digit(
            rest,
            remaining_batteries,
            trailing_batteries_to_ignore,
          )
      }
    [], _ -> panic as "We shouldnt get there"
  }
}
