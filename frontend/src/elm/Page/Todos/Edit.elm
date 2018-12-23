module Page.Todos.Edit exposing (Model, Msg(..), update, view)

import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Todos exposing (todoDecoder)
import Entities.Todo as Todo
import Html exposing (Html, a, button, div, form, h1, input, label, text, textarea)
import Html.Attributes exposing (checked, href, placeholder, style, type_, value)
import Html.Events exposing (onCheck, onInput, onSubmit)
import Http
import Json.Encode as JE
import Url.Builder as UB
import Utils.Todo exposing (idToString)


type Msg
    = OnInputChange String String
    | OnCheckChange String Bool
    | UpdateTodo
    | UpdatedTodo (Result Http.Error Model)


type alias Model =
    Todo.Model


update : Config.Model -> Msg -> Model -> ( Model, Cmd Msg )
update config msg model =
    case msg of
        OnInputChange "title" value ->
            ( { model | title = value }, Cmd.none )

        OnInputChange "content" value ->
            ( { model | content = Just value }, Cmd.none )

        OnCheckChange "completed" value ->
            ( { model | completed = value }, Cmd.none )

        OnInputChange _ _ ->
            ( model, Cmd.none )

        OnCheckChange _ _ ->
            ( model, Cmd.none )

        UpdateTodo ->
            ( model, updateTodo model )

        UpdatedTodo response ->
            ( model, Nav.pushUrl config.key (UB.absolute [ "todos", idToString model.id ] []) )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text <| "Editing Todo #" ++ idToString model.id ]
        , form [ onSubmit UpdateTodo ]
            [ div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Title:"
                    , input
                        [ type_ "text"
                        , placeholder "Title"
                        , style "margin-left" "10px"
                        , value model.title
                        , onInput (OnInputChange "title")
                        ]
                        []
                    ]
                ]
            , div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Content:"
                    , textarea
                        [ placeholder "Content"
                        , style "margin-left" "10px"
                        , value (Maybe.withDefault "" model.content)
                        , onInput (OnInputChange "content")
                        ]
                        []
                    ]
                ]
            , div [ style "margin-bottom" "10px" ]
                [ label []
                    [ text "Completed?"
                    , input
                        [ type_ "checkbox"
                        , style "margin-left" "10px"
                        , checked model.completed
                        , onCheck (OnCheckChange "completed")
                        ]
                        []
                    ]
                ]
            , div []
                [ button [] [ text "Save" ]
                ]
            ]
        , a [ href "/" ] [ text "Back home" ]
        ]


updateTodo : Model -> Cmd Msg
updateTodo formData =
    Http.request
        { method = "PUT"
        , headers = []
        , url = backendDomain ++ UB.absolute [ "todos", idToString formData.id ] []
        , body = Http.jsonBody <| todoPayload formData
        , expect = Http.expectJson UpdatedTodo todoDecoder
        , timeout = Nothing
        , tracker = Nothing
        }


todoPayload : Model -> JE.Value
todoPayload formData =
    JE.object
        [ ( "title", JE.string formData.title )
        , ( "content", JE.string (Maybe.withDefault "" formData.content) )
        , ( "completed", JE.bool formData.completed )
        ]
