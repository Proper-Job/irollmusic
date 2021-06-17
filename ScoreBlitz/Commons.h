/*
 *  Commons.h
 *  ScorePad
 *
 *  Created by Moritz Pfeiffer on 13.12.10.
 *  Copyright 2010 Alp Phone. All rights reserved.
 *
 */

/******************************************
 * Version Compile Settings
 ******************************************/

//#define DEBUG @"DEBUG"
#define APP_DEBUG 0

#define CopySampleData 1
#define CopySamplePdfsToDocumentsDirectory 1

#define NumberOfSampleScores 5000000

/******************************************
 * Basic App Settings
 ******************************************/


#define UIAppDelegate ((ScoreBlitzAppDelegate *)[[UIApplication sharedApplication] delegate])

#define kDidMigrateMeasureToVersionOnePointOne @"DidMigrateMeasureToVersionOnePointOne"

#define degreesToRadian(x) (M_PI * (x) / 180.0)

typedef enum {
    PagePickerShowAnimationFromLeft,
    PagePickerShowAnimationFromRight,
    PagePickerShowAnimationFromTop,
    PagePickerShowAnimationFromBottom
} PagePickerShowAnimation;

#define kDataBaseFileName @"iRollMusic"
#define kDataBaseFileExtension @"sqlite"
#define kDefaultDataDirectory @"DefaultScoreData"
#define kDefaultImageDirectory @"DefaultScoreImages"

// application directories
#define kApplicationScoresDirectory @"Scores"
#define kApplicationImportDirectory @"import"

/******************************************
 * App Store
 ******************************************/

#define k12monthSubscriptionIapItemIdentifier @"ch.irollmusic.ar.subscription.12"
#define k6monthSubscriptionIapItemIdentifier @"ch.irollmusic.ar.subscription.6"
#define k3monthSubscriptionIapItemIdentifier @"ch.irollmusic.ar.subscription.3"
#define k1monthSubscriptionIapItemIdentifier @"ch.irollmusic.ar.subscription.1"

#define kIapIdentifiers @[k12monthSubscriptionIapItemIdentifier, k6monthSubscriptionIapItemIdentifier, k3monthSubscriptionIapItemIdentifier, k1monthSubscriptionIapItemIdentifier]

#define kManageSubscriptionsUrl @"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions"

/******************************************
 * Rest API
 ******************************************/
#define kApiUser @"DO_NOT_DELETE"
#define kApiPassword @"Pinged1527-eXchanger"

#define kSharedSecretUrlParameter @"shared"
#define kReceiptDataUrlParameter @"receipt_data"

#define kReceiptValidationUrl @"https://irollmusic.sites.djangoeurope.com/iap/1.0/validate_auto_renewable_subscription"
#define kReceiptValidationProductIdentifierKey @"product_id"
#define kReceiptValidationExpirationDateKey @"expires_date"

#define kFeedBackSubmitURL @"https://irollmusic.sites.djangoeurope.com/feedback/1.0/submit"
#define kFeedBackSubmitUrlParameterAppVersion @"app_version"
#define kFeedBackSubmitUrlParameterOsVersion @"os_version"
#define kFeedBackSubmitUrlParameterMessage @"message"

/******************************************
 * AppID + DropBox
 ******************************************/

#define kiRollMusicAppStoreID 464286484

#define kDropBoxAppKey @"eo1zpc4iwkveyi8"
#define kGoogleAnalyticsAccountId @"UA-27873081-2"

/******************************************
 * Notifications
 ******************************************/
#define kLanguageChanged @"languageChanged"
#define kEditorWillDismissWithChangesNotification @"EditorWillDismissWithChangesNotification"
#define kWillPresentEditorNotification @"WillPresentEditorNotification"
#define kPerformanceControllerDidChangeScoreNotification @"PerformanceControllerDidChangeScoreNotification"
#define kPerformanceControllerWillPresentScorePickerNotification @"PerformancEControllerWillPresentScorePickerNotification"
#define kPerformanceControllerWillPresentHelpViewNotification @"PerformanceControllerWillPresentHelpViewNotification"
#define kPerformanceModeChangeNotificationNewModeKey @"PerformanceModeChangeNotificationModeKey"
#define kPerformanceModeChangeNotificationOldModeKey @"PerformanceModeChangeNotificationOldModeKey"
#define kSimpleScrollSpeedDidChangeNotification @"SimpleScrollSpeedDidChangeNotification"
#define kDidFinischCopyingDefaultData @"didFinischCopyingDefaultData"
#define kDisableGestureRecognizersInEditor @"disableGestureRecognizersInEditor"
#define kEnableGestureRecognizersInEditor @"enableGestureRecognizersInEditor"
#define kWillAnimateRotationToInterfaceOrientation @"willAnimateRotationToInterfaceOrientation"
#define kScoreDidRotateNotification @"ScoreDidRotateNotification"
#define kAirTurnUpArrowNotification @"kAirTurnUpArrowNotification"
#define kAirTurnDownArrowNotification @"kAirTurnDownArrowNotification"

#define kInterfaceOrientationKey @"interfaceOrientation"
#define kDurationKey @"duration"
#define kRotatedScoreObjectKey @"RotatedScoreObjectKey"

// new
#define kLibraryScoreListSelectionDidChange @"kLibraryScoreListSelectionDidChange"
#define kLibraryScoreListSelectionDidChangeObjectKey @"kLibraryScoreListSelectionDidChangeObjectKey"

#define kLibrarySetListSelectionDidChange @"kLibrarySetListSelectionDidChange"
#define kLibrarySetListSelectionDidChangeObjectKey @"kLibrarySetListSelectionDidChangeObjectKey"

#define kLibraryShowEditSetViewController @"kLibraryShowEditSetViewController"
#define kLibraryShowEditSetViewControllerObjectKey @"kLibraryShowEditSetViewControllerObjectKey"
#define kLibraryHideEditSetViewController @"kLibraryHideEditSetViewController"

#define kLibraryShowDropboxViewController @"LibraryShowDropboxViewController"

#define kLibraryDropboxAddFileToTransferListNotification @"kLibraryDropboxAddFileToTransferListNotification"
#define kLibraryDropboxAddFileToTransferListNotificationObject @"kLibraryDropboxAddFileToTransferListNotificationObject"

// dropbox
#define kFileSelectorInOutBoundCellToggled @"fileSelectorInOutBoundCellToggled"
#define kAnnotationsSelectorInOutBoundCellToggled @"annotationsSelectorInOutBoundCellToggled"
#define kTransferFileProgressDidChange @"transferFileProgressDidChange"
#define kTransferFileProgressDidChangeValue @"kTransferFileProgressDidChangeValue"
#define kTransferDidFail @"transferDidFail"
#define kTransferDidFailMessage @"kTransferDidFailMessage"
#define kDidCancelTransfer @"didCancelTransfer"
#define kTransferSuccess @"kTransferSuccess"
#define kShowActivityIndicatorInDropboxViewController @"showActivityIndicatorInDropboxViewController"
#define kHideActivityIndicatorInDropboxViewController @"hideActivityIndicatorInDropboxViewController"
#define kDropboxTransferManagerDidStartFileTransfer @"kDropboxTransferManagerDidStartFileTransfer"
#define kDropboxTransferManagerDidEndFileTransfer @"kDropboxTransferManagerDidEndFileTransfer"

// signAnnotations
#define kHideSignAnnotationViewController @"hideSignAnnotationViewController"

// Score Import and Analysing
#define kCancelScoreImportNotification @"kCancelScoreImportNotification"
#define kCancelScoreAnalysingNotification @"kCancelScoreAnalysingNotification"

// IAP
#define kSKProductsRequestDidReceiveResponse @"kSKProductsRequestDidReceiveResponse"
#define kSKProductsRequestDidReceiveResponseObjectKey @"kSKProductsRequestDidReceiveResponseObjectKey"
#define kProductPurchased @"kProductPurchased"
#define kProductPurchasedObjectKey @"kProductPurchasedObjectKey"

/******************************************
 * Versioning
 ******************************************/

typedef enum {
    DataVersion1,
    DataVersion2,
    DataVersion3
} DataVersion;

#define kCurrentDataVersion DataVersion3

/******************************************
 * Settings
 ******************************************/

#define kFirstBootFlag @"firstBootFlag"
#define kShowHelpers @"showHelpers"
#define kAnnotationPenColor @"annotationPenColor"
#define kAnnotationStandardPenColor 0
#define kAnnotationPenLineWidth @"annotationPenLineWidth"
#define kAnnotationStandardPenLineWidth 2
#define kAnnotationPenAlpha @"annotationPenAlpha"
#define kAnnotationStandardPenAlpha 1.0
#define kFeedBackText @"feedbackText"

#define kSettingSimpleModeScrollsContinuously @"SettingSimpleModeScrollsContinuously"
#define kSettingEnablePagingTapZones @"SettingEnablePagingTapZones"
#define kSettingPagingTapZoneFlashPageNumber @"SettingPagingTapZoneFlashPageNumber"
#define kSettingRollByMeasureShowArrow @"kSettingRollByMeasureShowArrow"
#define kSettingScrollPosition @"SettingScrollPosition"

// Language
#define kAppleLanguages @"AppleLanguages"
#define kAppLanguage @"AppLanguage"
#define kGermanLanguage @"de"
#define kEnglishLanguage @"en"
#define kFrenchLanguage @"fr"
#define kSpanishLanguage @"es"
#define kChineseSimplifiedLanguage @"zh-Hans"

// SignAnnotations
#define kRecentSignAnnotations @"recentSignAnnotations"
#define kMaxRecentSignAnnotations 8

#define MyLocalizedString(key, alter) [SettingsManager getLocalizedStringForKey:key alternateValue:alter]

/******************************************
 * Performance 
 ******************************************/

typedef enum {
	PerformanceModeSimpleScroll,
    PerformanceModeAdvancedScroll,
    PerformanceModePage
} PerformanceMode;

typedef enum {
    PerformanceScrollPositionTop,
    PerformanceScrollPositionMiddle,
    PerformanceScrollPositionBottom,
    PerformanceScrollPositionAutomatic
} PerformanceScrollPosition;

typedef enum {
    TapZonePagePositionTop,
    TapZonePagePositionBottom,
    TapZonePagePositionNone
} TapZonePagePosition;

typedef enum {
    PageNumberIndicatorPositionLeft,
    PageNumberIndicatorPositionRight,
    PageNumberIndicatorPositionCenter
} PageNumberIndicatorPosition;

#define kAvoidRecyclingScrollingPerformance 1  // This is a flag to toggle recycling in the scrolling performance mode
#define kAvoidRecyclingPagingPerformance 1  // This is a flag to toggle recycling in the paging performance mode

#define kMetronomeAudible @"MetronomeAudible"
#define kMetronomeCountInNumberOfBars @"MetronomeCountInNumberOfBars"
#define kVisualMetronome @"kVisualMetronome"

/******************************************
 * Settings Constants
 ******************************************/

#define kMaxRecentScores 7
#define kMaxRecentSets 6

/******************************************
 * Editor
 ******************************************/

typedef struct {
	int numerator;
	int denominator;
} AlpPhoneTimeSignature;

typedef enum {
	MeasureEditorOptionStateNormal,
	MeasureEditorOptionStateDetailed
} MeasureEditorOptionState;

typedef enum {
    EditorViewControllerTypeMeasures,
    EditorViewControllerTypeAnnotations,
    EditorViewControllerTypeStartMeasure
} EditorViewControllerType;

#define kWholeNote @"whole_note"
#define kHalfNote @"half_note"
#define kDottedHalfNote @"dotted_half_note"
#define kQuarterNote @"quarter_note"
#define kDottedQuarterNote @"dotted_quarter_note"
#define kEigthNote @"eigth_note"
#define kDottedEigthNote @"dotted_eigth_note"
#define kSixteenthNote @"sixteenth_note"

#define kMeasureMarkerViewWidth 65.0f
#define kMeasureMarkerViewHeight 75.0f
#define kMeasureMarkerViewCornerRadius 3.0f
#define kPenPickerColorDisplayCornerRadius 5.0f

#define kEditorActiveTempoNoteValue @"noteValue"
#define kEditorActiveTempoBpm @"bpm"

#define kPdfViewTag 9587
#define kEditorPreviewImageViewTag 9588

/******************************************
 * Annotations
 ******************************************/


#define kAnnotationBezierPaths @"bezierPaths"
#define kAnnotationBezierPathColors @"colorsForBezierPaths"
#define kAnnotationBezierPathAlpha @"alphaForBezierPaths"
#define kAnnotationStrings @"strings"
#define kAnnotationStringPoints @"pointsForStrings"
#define kAnnotationFontName @"fontNameForStrings"
#define kAnnotationFontSize @"fontSizeForStrings"

/******************************************
 * Jump types
 ******************************************/


typedef enum {
    APJumpTypeNone = 1001,
    APJumpTypeDaCapo = 1002,
    APJumpTypeDaCapoAlCoda = 1003,
    APJumpTypeDaCapoAlFine = 1004,
    APJumpTypeDaCapoAlSegno = 1005,
    APJumpTypeDalSegno = 1006,
    APJumpTypeDalSegnoAlCoda = 1007,
    APJumpTypeDalSegnoAlFine = 1008,
    APJumpTypeGoToCoda = 1009
} APJumpType;

/******************************************
 * File Extensions
 ******************************************/

#define kScoreBlitzFileExtension @"irm"
#define kScoreBlitzFileExtensionCapital @"IRM"
#define kPdfFileExtension @"pdf"
#define kPdfFileExtensionCapital @"PDF"
#define kPlistFileExtension @"plist"
#define kDataFileExtension @"data"
#define kIrmFileExtensions @[kScoreBlitzFileExtension, kScoreBlitzFileExtensionCapital]
#define kPdfFileExtensions @[kPdfFileExtension, kPdfFileExtensionCapital]

/******************************************
 * Score Manager
 ******************************************/
#define kPreviewImageSmallFormatString @"page_%d_preview_small.png"
#define kPreviewImageLargeFormatString @"page_%d_preview_large.png"
// Page number, x, y
#define kScoreImageTileFormatString @"page_%d_tile_%d_%d.png"
#define kScoreImageTileSize ((CGSize){256.0f, 256.0f})
#define kPreviewImageHeightSmall 327.0f
#define kPreviewImageWidthSmall 234.0f

typedef enum {
    TutorialTypeAnnotationsEditor = 886,
    TutorialTypeMeasureEditor,
    TutorialTypeStartMeasureEditor,
    TutorialTypeSimplePerformance,
    TutorialTypeAdvancedPerformance,
    TutorialTypePagingPerformance,
    TutorialTypeImport
} TutorialType;

/******************************************
 * Tutorial Movies
 ******************************************/
#define kLastTutorialMovieViewed @"LastTutorialMovieViewed"

/******************************************
 * Google Tracking
 ******************************************/
#define kTrackingEventButton @"button"

// Views
#define kCentralViewIdentifier @"Start"
#define kLibraryViewIdentifier @"Library"
#define kTutorialsViewIdentifier @"Tutorials"
#define kSettingsViewIdentifier @"Settings"
#define kAboutViewIdentifier @"About"
#define kExportDialogViewController @"Export Dialog"

// Action labels
#define kExportPdf @"Export PDF File"
#define kExportIrm @"Export IRM File"
#define kPrintScore @"Print Score"
