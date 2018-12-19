module Page.Todos.Show exposing (view)

import Html exposing (Html, a, div, h1, p, span, strong, text)
import Html.Attributes exposing (class, href)
import Http
import Page.Home exposing (Todo)
import Utils.Todo exposing (idToString)


type alias Model =
    Maybe Todo


todoView todo =
    div []
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
        , div [ class "links" ]
            [ a [ href "/" ] [ text "Back home" ]
            , span [ class "divider" ] []
            , a [ href ("/todos" ++ idToString todo.id) ] [ text "Edit" ]
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
