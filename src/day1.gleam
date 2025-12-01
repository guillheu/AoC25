import gleam/int
import gleam/io
import gleam/list
import gleam/string
import gleeunit/should
import simplifile

const filename = "day1.txt"

pub fn pb2() {
  let #(current_cursor, zero_counter) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.fold(#(50, 0), fn(acc, operation) {
      let #(current_cursor, zero_counter) = acc

      io.println("Next line: " <> operation)
      io.println("Current cursor: " <> int.to_string(current_cursor))
      io.println("Current zero count: " <> int.to_string(zero_counter))

      let move_by = case operation {
        "R" <> val -> {
          val
          |> int.parse
          |> should.be_ok
        }
        "L" <> val -> {
          val
          |> int.parse
          |> should.be_ok
          |> int.negate
        }
        _ -> panic as { "invalid line: " <> operation }
      }

      let #(new_cursor, new_zero_counter) =
        modulo_but_did_it_cross_zero(current_cursor, move_by, zero_counter)

      io.println("New cursor: " <> new_cursor |> int.to_string)
      io.println("New zero count: " <> new_zero_counter |> int.to_string)
      io.println("\n######### NEXT OP ##########\n")
      #(new_cursor, new_zero_counter)
    })

  zero_counter
  |> int.to_string
  |> io.println
}

fn modulo_but_did_it_cross_zero(
  last_cursor: Int,
  move_by: Int,
  zero_counter: Int,
) -> #(Int, Int) {
  io.println(
    "\nLast cursor: "
    <> int.to_string(last_cursor)
    <> "\nMove by: "
    <> int.to_string(move_by),
  )
  let move_magnitude =
    int.divide(move_by, 100) |> should.be_ok |> int.absolute_value

  let reduced_move = move_by % 100

  let new_raw_cursor = last_cursor + reduced_move

  let new_zero_crosses =
    case new_raw_cursor {
      x if x <= 0 && last_cursor != 0 -> 1
      x if x >= 100 -> 1
      _ -> 0
    }
    + move_magnitude

  io.println("Move magnitude: " <> int.to_string(move_magnitude))
  io.println("Reduced move: " <> int.to_string(reduced_move))
  io.println("New raw cursor: " <> int.to_string(new_raw_cursor))

  #(
    new_raw_cursor |> int.modulo(100) |> should.be_ok,
    zero_counter + new_zero_crosses,
  )
}

pub fn pb1() {
  let #(current_cursor, zero_counter) =
    simplifile.read(filename)
    |> should.be_ok
    |> string.split("\n")
    |> list.fold(#(50, 0), fn(acc, operation) {
      let #(current_cursor, zero_counter) = acc

      io.println("Next line: " <> operation)
      io.println("Current cursor: " <> int.to_string(current_cursor))
      io.println("Current zero count: " <> int.to_string(zero_counter))

      let current_cursor = case operation {
        "R" <> val -> {
          val
          |> int.parse
          |> should.be_ok
          |> int.add(current_cursor)
          |> int.modulo(100)
          |> should.be_ok
        }
        "L" <> val -> {
          let by =
            val
            |> int.parse
            |> should.be_ok
          int.subtract(current_cursor, by)
          |> int.modulo(100)
          |> should.be_ok
        }
        _ -> panic as { "invalid line: " <> operation }
      }
      let new_zero_counter = case current_cursor == 0 {
        False -> zero_counter
        True -> zero_counter + 1
      }
      io.println("COMPUTING BRRRRR...")
      io.println("New cursor: " <> current_cursor |> int.to_string)
      io.println("New zero count: " <> new_zero_counter |> int.to_string)
      io.println("NEXT OP\n")
      #(current_cursor, new_zero_counter)
    })

  zero_counter
  |> int.to_string
  |> io.println
}
