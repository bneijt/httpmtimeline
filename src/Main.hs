{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Control.Monad.IO.Class (liftIO)
import System.Posix.Files
import System.FilePath.Find (find, extension, always, (==?), (||?))
import Data.Aeson

-- | Set MIME to 'application/json' and write given object into
-- 'Response' body.
writeJSON :: (MonadSnap m, ToJSON a) => a -> m ()
writeJSON a = do
  jsonResponse
  writeLBS . encode $ a

-- | Mark response as 'application/json'
jsonResponse :: MonadSnap m => m ()
jsonResponse = modifyResponse $ setHeader "Content-Type" "application/json"

imageHostingBasePath :: FilePath
imageHostingBasePath = "images/"

getMTimeInteger :: FilePath -> IO Int
getMTimeInteger filepath = do
    status <- getFileStatus filepath
    let mtime = modificationTime status
    return (fromEnum mtime)

--Remove basepath from filenames
dropBasepath :: FilePath -> [FilePath] -> [FilePath]
dropBasepath basepath filenames = map (\x -> drop (length basepath) x) filenames

mtimeFilenameTuplesOf :: [FilePath] -> FilePath -> IO [(Int, FilePath)]
mtimeFilenameTuplesOf filenames basepath = do
    mtimes <- mapM getMTimeInteger filenames
    return $ zip mtimes (dropBasepath basepath filenames)

listImagesWithCtime :: IO [(Int, FilePath)]
listImagesWithCtime = do
    files <- find always (extension ==? ".jpg" ||? extension ==? ".png") imageHostingBasePath
    mtimeFilenameTuplesOf files imageHostingBasePath


main :: IO ()
main = quickHttpServe site

site :: Snap ()
site =
    route [ ("images/index.json", imageIndexHandler)
    , ("images/", serveDirectory imageHostingBasePath)
          ] <|> (serveDirectory "static")

imageIndexHandler :: Snap ()
imageIndexHandler = do
        listing <- liftIO listImagesWithCtime
        writeJSON (listing :: [(Int, FilePath)])
