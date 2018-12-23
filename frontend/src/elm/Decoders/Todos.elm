module Decoders.Todos exposing (todoDecoder, todosListDecoder)

import Entities.Todo as Todo
import Json.Decode as JD


todosListDecoder : JD.Decoder (List Todo.Model)
todosListDecoder =
    JD.list todoDecoder


todoDecoder : JD.Decoder Todo.Model
todoDecoder =
    JD.map4 Todo.Model
        (JD.field "title" JD.string)
        (JD.field "content" JD.string |> JD.maybe)
        (JD.field "completed" JD.bool)
        (JD.field "id" JD.int |> JD.maybe)
