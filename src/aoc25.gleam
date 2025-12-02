import day1
import day2
import gleam/int
import gleam/io

pub fn main() -> Nil {
  let count = day2.pb2()
  io.println("The count is " <> count |> int.to_string)
}
