{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}

module Web.Slack
  ( Cli(..)
  , mkCli
  , run
  , mkManager
  )
  where

-- base
import Data.Proxy (Proxy(..))
import GHC.Generics (Generic)

-- generics-sop
import qualified Generics.SOP (Generic)

-- http-client
import Network.HTTP.Client (Manager, newManager)

-- http-client-tls
import Network.HTTP.Client.TLS (tlsManagerSettings)

-- servant
import Servant.API

-- servant-client
import Servant.Client
import Servant.Client.Generic

-- slack-web
import qualified Web.Slack.Auth as Auth
import qualified Web.Slack.Channel as Channel
import qualified Web.Slack.Chat as Chat

-- transformers
import Control.Monad.IO.Class


-- |
--
--

type Api =
    "auth.test"
      :> ReqBody '[FormUrlEncoded] Auth.TestReq
      :> Post '[JSON] Auth.TestRsp
  :<|>
    "channels.create"
      :> ReqBody '[FormUrlEncoded] Channel.CreateReq
      :> Post '[JSON] Channel.CreateRsp
  :<|>
    "chat.postMessage"
      :> ReqBody '[FormUrlEncoded] Chat.PostMsgReq
      :> Post '[JSON] Chat.PostMsgRsp


-- |
--
--

data Cli =
  Cli
    { -- |
      --
      --

      authTest
        :: Auth.TestReq
        -> ClientM Auth.TestRsp

      -- |
      --
      --

    , channelsCreate
        :: Channel.CreateReq
        -> ClientM Channel.CreateRsp

      -- |
      --
      --

    , chatPostMessage
        :: Chat.PostMsgReq
        -> ClientM Chat.PostMsgRsp

    }
  deriving (Generic)


-- |
--
--

instance Generics.SOP.Generic Cli


-- |
--
--

instance (Client Api ~ cli) => ClientLike cli Cli


-- |
--
--

mkCli :: Cli
mkCli =
  mkClient (client (Proxy :: Proxy Api))


-- |
--
--

run
  :: MonadIO m
  => Manager
  -> ClientM a
  -> m (Either ServantError a)
run manager =
  let
    baseUrl =
      BaseUrl Https "slack.com" 443 "/api"

  in
    liftIO . flip runClientM (ClientEnv manager baseUrl)


-- |
--
--

mkManager :: IO Manager
mkManager =
  newManager tlsManagerSettings
