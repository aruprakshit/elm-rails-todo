module Decoders.Todos exposing (todoDecoder, todosListDecoder)

import Json.Decode as JD
import Page.Home exposing (Todo)


todosListDecoder : JD.Decoder (List Todo)
todosListDecoder =
    JD.list todoDecoder


todoDecoder : JD.Decoder Todo
todoDecoder =
    JD.map4 Todo
        (JD.field "title" JD.string)
        (JD.field "content" JD.string |> JD.maybe)
        (JD.field "completed" JD.bool)
        (JD.field "id" JD.int |> JD.maybe)
