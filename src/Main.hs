{-# LANGUAGE OverloadedStrings #-}

module Main where

import Control.Applicative
import Snap.Core
import Snap.Util.FileServe
import Snap.Http.Server
import Snap.Extras.JSON
import Control.Monad.IO.Class (liftIO)
import System.Posix.Files
import System.FilePath.Find (find, extension, always, (==?), (||?))

imageHostingBasePath :: FilePath
imageHostingBasePath = "images/"

getMTimeInteger :: FilePath -> IO Integer
getMTimeInteger filepath = do
    status <- getFileStatus filepath
    let mtime = modificationTime status
    return ((read . show) mtime :: Integer)

--Remove basepath from filenames
dropBasepath :: FilePath -> [FilePath] -> [FilePath]
dropBasepath basepath filenames = map (\x -> drop (length basepath) x) filenames

mtimeFilenameTuplesOf :: [FilePath] -> FilePath -> IO [(Integer, FilePath)]
mtimeFilenameTuplesOf filenames basepath = do
    mtimes <- mapM getMTimeInteger filenames
    return $ zip mtimes (dropBasepath basepath filenames)

listImagesWithCtime :: IO [(Integer, FilePath)]
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
        writeJSON (listing :: [(Integer, FilePath)])
