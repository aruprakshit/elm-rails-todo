module Page.Todos.Edit exposing (Model, Msg(..), update, view)

import Browser.Navigation as Nav
import Config exposing (AuthState(..), backendDomain)
import Decoders.Todos exposing (todoDecoder)
import Entities.Todo as Todo
import Html exposing (Html, a, button, div, form, h1, input, label, text, textarea)
import Html.Attributes exposing (checked, class, href, placeholder, style, type_, value)
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
            ( model, updateTodo config model )

        UpdatedTodo response ->
            ( model, Nav.pushUrl config.key (UB.absolute [ "todos", idToString model.id ] []) )


view : Model -> List (Html Msg)
view model =
    [ div [ class "row" ]
        [ div [ class "col-12" ]
            [ h1 [] [ text <| "Editing Todo #" ++ idToString model.id ]
            , form [ onSubmit UpdateTodo ]
                [ div [ class "form-group" ]
                    [ label [] [ text "Title:" ]
                    , input
                        [ type_ "text"
                        , placeholder "Title"
                        , class "form-control col-4"
                        , value model.title
                        , onInput (OnInputChange "title")
                        ]
                        []
                    ]
                , div [ class "form-group" ]
                    [ label [] [ text "Content:" ]
                    , textarea
                        [ placeholder "Content"
                        , class "form-control"
                        , value (Maybe.withDefault "" model.content)
                        , onInput (OnInputChange "content")
                        ]
                        []
                    ]
                , div [ class "form-group form-check" ]
                    [ input
                        [ type_ "checkbox"
                        , class "form-check-input"
                        , checked model.completed
                        , onCheck (OnCheckChange "completed")
                        ]
                        []
                    , label [ class "form-check-label" ] [ text "Completed?" ]
                    ]
                , div []
                    [ button [ class "btn btn-primary" ] [ text "Save" ]
                    ]
                ]
            ]
        ]
    , div [ class "card mt-4" ]
        [ div [ class "card-body d-flex" ]
            [ a [ href "/", class "btn btn-primary" ] [ text "Back home" ]
            ]
        ]
    ]


updateTodo : Config.Model -> Model -> Cmd Msg
updateTodo config formData =
    let
        authToken =
            case config.token of
                Authenticated value ->
                    value

                NotAuthenticated ->
                    ""
    in
    Http.request
        { method = "PUT"
        , headers =
            [ Http.header "Authorization" authToken
            ]
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
