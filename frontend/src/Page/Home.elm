module Page.Home exposing (Todo, initialTodo, view)

import Html exposing (Html, a, div, table, tbody, td, text, th, thead, tr)
import Html.Attributes exposing (href)


type alias Todo =
    { title : String
    , content : Maybe String
    , completed : Bool
    , id : Maybe Int
    }


initialTodo =
    Todo "" Nothing False Nothing


view : List Todo -> Html msg
view todos =
    div []
        [ table []
            [ thead []
                [ tr []
                    [ th [] [ text "Title" ]
                    , th [] [ text "Content" ]
                    , th [] [ text "Completed?" ]
                    ]
                ]
            , tbody [] (tableBody todos)
            ]
        , a [ href "todos/new" ] [ text "Create Todo" ]
        ]


tableBody : List Todo -> List (Html msg)
tableBody todos =
    List.map
        (\todo ->
            tr []
                [ td [] [ text todo.title ]
                , td [] [ text (Maybe.withDefault "-" todo.content) ]
                , td []
                    [ text
                        (if todo.completed then
                            "✓"

                         else
                            "˟"
                        )
                    ]
                ]
        )
        todos
