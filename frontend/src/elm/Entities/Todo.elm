module Entities.Todo exposing (Model, initialModel)


type alias Model =
    { title : String
    , content : Maybe String
    , completed : Bool
    , id : Maybe Int
    }


initialModel : Model
initialModel =
    Model "" Nothing False Nothing
