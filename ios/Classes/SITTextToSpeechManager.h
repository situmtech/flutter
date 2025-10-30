//
//  SITTextToSpeechManager.h
//  situm_flutter
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SITTextToSpeechManager : NSObject

- (instancetype)init;

/**
 Processes and speaks aloud a message that MapView's wants to communicate to the user through the 'ui.speak_aloud_text' javascript message.
 
 @param payload An internal dictionary from within MapView that contains the required information and parameters to be able to speak aloud texts.
 */
- (void)speakWithPayload:(NSDictionary<id, id> * _Nullable)payload;

@end

NS_ASSUME_NONNULL_END
