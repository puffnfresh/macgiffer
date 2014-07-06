#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>
#import <ApplicationServices/ApplicationServices.h>

useconds_t SECOND = 1000000;

int main(int argc, char **argv) {
  if (argc != 5) {
    fprintf(stderr, "Usage: ./macgiffer delay interval length filename\n");
    return 1;
  }

  float delay = atof(argv[1]);
  float interval = atof(argv[2]);
  float length = atof(argv[3]);
  NSString *path = [NSString stringWithCString:argv[4] encoding:NSASCIIStringEncoding];

  usleep(SECOND * delay);

  unsigned int imageCount = length / interval;

  CGDisplayCount displayCount = 0;
  CGGetActiveDisplayList(0, NULL, &displayCount);

  CGDirectDisplayID *displays = calloc((size_t)displayCount, sizeof(CGDirectDisplayID));
  CGGetActiveDisplayList(displayCount, displays, &displayCount);

  CGImageDestinationRef destination = CGImageDestinationCreateWithURL((CFURLRef)[NSURL fileURLWithPath:path], kUTTypeGIF, imageCount, NULL);

  NSDictionary *frameProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:interval] forKey:(NSString *)kCGImagePropertyGIFDelayTime] forKey:(NSString *)kCGImagePropertyGIFDictionary];
  NSDictionary *gifProperties = [NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount] forKey:(NSString *)kCGImagePropertyGIFDictionary];

  for (unsigned int i = 0; i < imageCount; i++) {
    CGImageRef image = CGDisplayCreateImage(displays[0]);
    CGImageDestinationAddImage(destination, image, (CFDictionaryRef)frameProperties);
    CGImageRelease(image);
    usleep(SECOND * interval);
  }

  CGImageDestinationFinalize(destination);
  free(displays);
  CFRelease(destination);
}
