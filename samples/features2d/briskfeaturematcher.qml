import 'lcvcore' 1.0
import "lcvimgproc" 1.0
import "lcvfeatures2d" 1.0

Grid{
    columns : 2
    
    // Train images
    
    property string imagePath : codeDocument.path + '/../_images/'
    property string trainImage : imagePath + 'object_101_piano_train1.jpg'
    property string queryImage : imagePath + 'object_101_piano_query.jpg'
    
    ImRead{
        id: trainImageLoader
        
        visible : false
        
        property variant images
        property variant keypoints
        
        Component.onCompleted : {
            var imageArray    = new Array()
            var keypointArray = new Array()
            
            file = trainImage
            imageArray.push(output.createOwnedObject())
            keypointArray.push(trainFeatureDetect.keypoints.createOwnedObject())
            
            images    = imageArray
            keypoints = keypointArray
        }
    }
    
    BriskFeatureDetector{
        id : trainFeatureDetect
        input : trainImageLoader.output
        Component.onCompleted : {
            initialize(30, 3)
        }
    }
    
    BriskDescriptorExtractor{
        keypoints : trainFeatureDetect.keypoints
        onDescriptorsChanged : {
            descriptorMatcher.add(descriptors)
            descriptorMatcher.train();
        }
    }
        
    // Query Image
    
    
    ImRead{
        id : queryImageLoader
        file : queryImage
    }
    
    BriskFeatureDetector{
        id : queryFeatureDetect
        input : queryImageLoader.output
        Component.onCompleted : {
            initialize(30, 3)
        }
    }
    
    BriskDescriptorExtractor{
        id : queryFeatureExtract
        keypoints : queryFeatureDetect.keypoints
    }
    
    // Matching
    
    BruteForceMatcher{
        id : descriptorMatcher
        queryDescriptors : queryFeatureExtract.descriptors
        knn : 1
    }
    
    DrawMatches{
        keypoints1 : queryFeatureDetect.keypoints
        keypoints2 : trainImageLoader.keypoints[0]
        matches1to2 : descriptorMatcher.matches
        matchIndex : 0
    }
    
}
