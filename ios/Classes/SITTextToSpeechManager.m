//
//  SITTextToSpeechManager.m
//  situm_flutter
//

#import "SITTextToSpeechManager.h"

@interface SITTextToSpeechManager () <AVSpeechSynthesizerDelegate>
@property (nonatomic, strong) AVSpeechSynthesizer *synthesizer;
@end

@implementation SITTextToSpeechManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.synthesizer = [AVSpeechSynthesizer new];
        self.synthesizer.delegate = self;
    }
    return self;
}

- (void)speakWithPayload:(NSDictionary<id,id> *)payload {
    
    if (![payload isKindOfClass:[NSDictionary class]]) return;
    
    NSString *text = payload[@"text"];
    NSString *lang = payload[@"lang"];
    NSNumber *pitchNum = payload[@"pitch"];
    NSNumber *rateNum  = payload[@"rate"];
    
    if (![text isKindOfClass:[NSString class]] ||
        ![lang isKindOfClass:[NSString class]] ||
        ![pitchNum isKindOfClass:[NSNumber class]] ||
        ![rateNum isKindOfClass:[NSNumber class]]) {
        return;
    }
    
    float pitch = pitchNum.floatValue;
    float rate  = rateNum.floatValue;
    
    [self speakText:text language:lang rate:rate pitch:pitch];
}

- (void)speakText:(NSString *)text language:(NSString *)language rate:(float)rate pitch:(float)pitch {
    if (text.length == 0) return;
    
    AVSpeechUtterance *utt = [[AVSpeechUtterance alloc] initWithString:text];
    utt.rate = rate;
    utt.pitchMultiplier = pitch;
    
    AVSpeechSynthesisVoice *voice = [AVSpeechSynthesisVoice voiceWithLanguage:language];
    if (voice) {
        utt.voice = voice;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([self.synthesizer isSpeaking]) {
            [self.synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
        }
        [self.synthesizer speakUtterance:utt];
    });
}

@end
