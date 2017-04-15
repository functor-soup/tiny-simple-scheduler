module SubJobs
  ( convertJobIntoSubJobs
  , execSubJobs
  ) where

import Control.Applicative
import Control.Concurrent
import Control.Concurrent.Async
import Data.Time
import Jobs
import Prelude hiding (id)

data SubJob a = SubJob
  { jobId :: Int
  , delay :: Int
  , hitNo :: Int
  , job_ :: IO a
  }

convertJobIntoSubJobs :: UTCTime -> Job a -> [SubJob a]
convertJobIntoSubJobs currentTime x =
  let timeDelays = calculateDelay currentTime (startDate x) (interval x) (hits x)
      zippedDelays = zip [1 ..] timeDelays
  in map (\(i, z) -> SubJob (id x) z i (job x)) zippedDelays

execSubJob :: SubJob a -> IO a
execSubJob x = threadDelay (delay x) >> (job_ x)

execSubJobs :: [SubJob a] -> IO [a]
execSubJobs = mapConcurrently execSubJob
