module Page.Todos.Show exposing (view)

import Entities.Todo as Todo
import Html exposing (Html, a, div, h1, p, span, strong, text)
import Html.Attributes exposing (class, href)
import Url.Builder as UB
import Utils.Todo exposing (idToString)


type alias Model =
    Maybe Todo.Model


todoView : Todo.Model -> Html msg
todoView todo =
    div []
        [ div [ class "row" ]
            [ div [ class "col-12" ]
                [ h1 [] [ text <| "Viewing Todo #" ++ idToString todo.id ]
                , div []
                    [ p []
                        [ strong [] [ text "Title:  " ]
                        , text todo.title
                        ]
                    ]
                , div []
                    [ p []
                        [ strong [] [ text "Content:  " ]
                        , text (Maybe.withDefault "" todo.content)
                        ]
                    ]
                , div []
                    [ p []
                        [ strong [] [ text "Status:  " ]
                        , text
                            (if todo.completed then
                                "Finished"

                             else
                                "Not Finished"
                            )
                        ]
                    ]
                ]
            ]
        , div [ class "card mt-4" ]
            [ div [ class "card-body d-flex" ]
                [ a [ href "/", class "btn btn-primary" ] [ text "Back home" ]
                , a [ class "btn btn-primary ml-auto", href (UB.absolute [ "todos", idToString todo.id, "edit" ] []) ] [ text "Edit" ]
                ]
            ]
        ]


view : Model -> Html msg
view model =
    let
        content =
            case model of
                Just todo ->
                    todoView todo

                Nothing ->
                    text "Loading"
    in
    content
