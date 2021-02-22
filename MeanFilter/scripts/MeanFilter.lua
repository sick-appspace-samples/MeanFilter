--[[----------------------------------------------------------------------------

  Application Name: 
  MeanFilter                                                                                                                      
               
  Summary 
  Applying mean filter and echo filter on scans read from a file    
                                                                         
  Description:
  This sample shows how to apply a mean filter and an echo filter to scans read 
  from file and displays the filtered scan as a point cloud. A file scan provider is 
  created and and the scans from the file are played back. The filtered scan is 
  shown in the PointCloud viewer on the webpage.
  In addition, the noise is estimated as positive difference between the mean distances 
  and the distances of the last scan of a block.
  
  How to run:
  Starting this sample is possible either by running the app (F5) or 
  debugging (F7+F10). Output is printed to the console and the transformed 
  point cloud can be seen on the viewer in the web page. The playback stops 
  after the last scan in the file. To replay, the sample must be restarted.
  To run this sample, a device with AppEngine >= 2.5.0 is required.
  
  Implementation: 
  To run with real device data, the file provider has to be exchanged with the 
  appropriate scan provider.
  
------------------------------------------------------------------------------]]

--Start of Global Scope--------------------------------------------------------- 
local scanCounter = 0
local SCAN_FILE_PATH = "resources/TestScenario.xml"
print("Input File: ", SCAN_FILE_PATH)

-- Check device capabilities
assert(View,"View not available, check capability of connected device")
assert(Scan,"Scan not available, check capability of connected device")
assert(Scan.Transform,"Transform not available, check capability of connected device")
assert(Scan.MeanFilter,"MeanFilter not available, check capability of connected device")
assert(Scan.EchoFilter,"EchoFilter not available, check capability of connected device")

-- Create a transform instance to convert the Scan to a PointCloud
transform = Scan.Transform.create()
assert(transform,"Transform could not be created. Check the device capabilites")

-- Create a viewer instance
viewer = View.create()
assert(viewer,"Viewer was not created.\n")
viewer:setID("viewer3D")
 
-- Create the required filter
echoFilter = Scan.EchoFilter.create()
assert(echoFilter,"Error: EchoFilter could not be created")
meanFilter = Scan.MeanFilter.create()
assert(meanFilter,"Error: MeanFilter could not be created")

-- Set filter parameter
Scan.EchoFilter.setType(echoFilter, "FIRST")
Scan.MeanFilter.setAverageDepth(meanFilter,3)
Scan.MeanFilter.setEnabled(meanFilter,true)

-- Create provider. Providing starts automatically with the register call
-- which is found below the callback function
provider = Scan.Provider.File.create()
assert(provider,"Error: Scan file provider not started")
-- Set the path
Scan.Provider.File.setFile(provider, SCAN_FILE_PATH)
-- Set the DataSet of the recorded data which should be used.
Scan.Provider.File.setDataSetID(provider, 1)

--End of Global Scope----------------------------------------------------------- 

--Start of Function and Event Scope---------------------------------------------

--------------------------------------------------------------------------------
-- Calculate the average distance differences which are not larger than the 
-- given threshold, processes the first echo only!
--------------------------------------------------------------------------------
function getAverageDelta(inputScan, filteredScan, threshold, printDetails)
  
  -- Get the beam and echo counts
  local beamCountInput = Scan.getBeamCount(inputScan)
  local beamCountFiltered = Scan.getBeamCount(filteredScan)
  
  local count = 0
  local sum = 0.0
  
  -- Checks
  if ( beamCountInput == beamCountFiltered ) then
    -- Print beams with different distances
    local distanceInput = Scan.toVector(inputScan,"DISTANCE", 0)
    local distanceMean  = Scan.toVector(filteredScan,"DISTANCE", 0)
    for iBeam=1, beamCountInput do
      
      local d1 = distanceInput[iBeam]
      local d2 = distanceMean[iBeam]
      local delta = math.abs(d1-d2)
      -- if the delta is too big it is NOT a statistical variation
      if ( delta < threshold ) then
        count = count + 1
        sum = sum + delta
      end
    end
    
    local average = 0.0
    if ( count > 0) then
      average = sum / count
    end
    -- Print(count, sum, average)
    return count, sum, average
  end
end

-- Callback function to process new scans
function handleNewScan(scan)

  local startTime = DateTime.getTimestamp()
  scanCounter = scanCounter + 1
  
  -- Clone input scan
  local inputScan = Scan.clone(scan)
  
  -- Call mean filter
  scan = Scan.EchoFilter.filter(echoFilter, scan)
  local filteredScan = Scan.MeanFilter.filter(meanFilter, scan)
  if ( filteredScan ~= nil ) then
  
    -- Analyze filtered scan: get estimation of noise level
    -- larger differences are considered as real and are ignored
    local threshold = 20.0 
    local count, sum, average = getAverageDelta(inputScan, filteredScan, threshold, true)
    print(DateTime.getTime(),string.format("Scan %6d (%3d ms): average difference between mean distance and distance of last scan = %10.2f", 
                        scanCounter, DateTime.getTimestamp() - startTime, average))
    
    -- Transform to PointCloud to view in the PointCloud viewer on the webpage
    local pointCloud = Scan.Transform.transformToPointCloud(transform, filteredScan)
    View.add(viewer, pointCloud)
    View.present(viewer)
  end
end
-- Register callback function to "OnNewScan" event. 
-- This call also starts the playback of scans
Scan.Provider.File.register(provider, "OnNewScan", handleNewScan)

--End of Function and Event Scope------------------------------------------------