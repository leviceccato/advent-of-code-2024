import gleam/dict
import gleam/int
import gleam/io
import gleam/list
import gleam/option
import gleam/pair
import gleam/result
import gleam/string

import simplifile

pub fn main() {
  let assert Ok(input) = simplifile.read("./input/day_1.txt")

  let maybe_raw_lines =
    input
    |> string.trim
    |> string.split("\n")
    |> list.map(fn(raw_line) {
      case string.split(raw_line, "   ") {
        [raw_id_1, raw_id_2] -> Ok(#(raw_id_1, raw_id_2))
        _ -> Error("row malformed")
      }
    })
    |> result.all
    |> result.map_error(io.debug)

  use raw_lines <- result.try(maybe_raw_lines)

  let maybe_lines =
    raw_lines
    |> list.map(fn(raw_ids) {
      case int.parse(raw_ids.0), int.parse(raw_ids.1) {
        Ok(id_1), Ok(id_2) -> Ok(#(id_1, id_2))
        _, _ -> Error("id not a number")
      }
    })
    |> result.all
    |> result.map_error(io.debug)

  use lines <- result.try(maybe_lines)

  let list_1 =
    lines
    |> list.map(pair.first)
    |> list.sort(int.compare)

  let list_2 =
    lines
    |> list.map(pair.second)
    |> list.sort(int.compare)

  let lists = list.zip(list_1, list_2)

  let total_distance =
    lists
    |> list.map(fn(ids) {
      int.subtract(ids.0, ids.1)
      |> int.absolute_value
    })
    |> int.sum

  io.debug(total_distance)

  let id_counts =
    list_2
    |> list.fold(dict.new(), fn(counts, id) {
      counts
      |> dict.upsert(id, fn(maybe_count) {
        case maybe_count {
          option.Some(count) -> count + 1
          option.None -> 1
        }
      })
    })

  let similarity_score =
    list_1
    |> list.fold(0, fn(maybe_score, id) {
      let count =
        id_counts
        |> dict.get(id)
        |> result.unwrap(0)

      maybe_score + id * count
    })

  io.debug(similarity_score)

  Ok(Nil)
}
