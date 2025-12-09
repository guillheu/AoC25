import day1
import day2
import day3
import day4
import day5
import day6
import day7
import day8
import day9
import gleam/int
import gleam/io

pub fn main() -> Nil {
  let count = day9.pb2()
  io.println("The count is " <> count |> int.to_string)
}
