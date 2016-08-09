// Namespaced Header

#ifndef __NS_SYMBOL
// We need to have multiple levels of macros here so that __NAMESPACE_PREFIX_ is
// properly replaced by the time we concatenate the namespace prefix.
#define __NS_REWRITE(ns, symbol) ns ## _ ## symbol
#define __NS_BRIDGE(ns, symbol) __NS_REWRITE(ns, symbol)
#define __NS_SYMBOL(symbol) __NS_BRIDGE(YOUR_PREFIX_HERE, symbol)
#endif


// Classes
#ifndef AFCompoundResponseSerializer
#define AFCompoundResponseSerializer __NS_SYMBOL(AFCompoundResponseSerializer)
#endif

#ifndef AFHTTPBodyPart
#define AFHTTPBodyPart __NS_SYMBOL(AFHTTPBodyPart)
#endif

#ifndef AFHTTPRequestOperation
#define AFHTTPRequestOperation __NS_SYMBOL(AFHTTPRequestOperation)
#endif

#ifndef AFHTTPRequestOperationManager
#define AFHTTPRequestOperationManager __NS_SYMBOL(AFHTTPRequestOperationManager)
#endif

#ifndef AFHTTPRequestSerializer
#define AFHTTPRequestSerializer __NS_SYMBOL(AFHTTPRequestSerializer)
#endif

#ifndef AFHTTPResponseSerializer
#define AFHTTPResponseSerializer __NS_SYMBOL(AFHTTPResponseSerializer)
#endif

#ifndef AFHTTPSessionManager
#define AFHTTPSessionManager __NS_SYMBOL(AFHTTPSessionManager)
#endif

#ifndef AFImageResponseSerializer
#define AFImageResponseSerializer __NS_SYMBOL(AFImageResponseSerializer)
#endif

#ifndef AFJSONRequestSerializer
#define AFJSONRequestSerializer __NS_SYMBOL(AFJSONRequestSerializer)
#endif

#ifndef AFJSONResponseSerializer
#define AFJSONResponseSerializer __NS_SYMBOL(AFJSONResponseSerializer)
#endif

#ifndef AFMultipartBodyStream
#define AFMultipartBodyStream __NS_SYMBOL(AFMultipartBodyStream)
#endif

#ifndef AFNetworkReachabilityManager
#define AFNetworkReachabilityManager __NS_SYMBOL(AFNetworkReachabilityManager)
#endif

#ifndef AFPropertyListRequestSerializer
#define AFPropertyListRequestSerializer __NS_SYMBOL(AFPropertyListRequestSerializer)
#endif

#ifndef AFPropertyListResponseSerializer
#define AFPropertyListResponseSerializer __NS_SYMBOL(AFPropertyListResponseSerializer)
#endif

#ifndef AFQueryStringPair
#define AFQueryStringPair __NS_SYMBOL(AFQueryStringPair)
#endif

#ifndef AFSecurityPolicy
#define AFSecurityPolicy __NS_SYMBOL(AFSecurityPolicy)
#endif

#ifndef AFStreamingMultipartFormData
#define AFStreamingMultipartFormData __NS_SYMBOL(AFStreamingMultipartFormData)
#endif

#ifndef AFURLConnectionOperation
#define AFURLConnectionOperation __NS_SYMBOL(AFURLConnectionOperation)
#endif

#ifndef AFURLSessionManager
#define AFURLSessionManager __NS_SYMBOL(AFURLSessionManager)
#endif

#ifndef AFURLSessionManagerTaskDelegate
#define AFURLSessionManagerTaskDelegate __NS_SYMBOL(AFURLSessionManagerTaskDelegate)
#endif

#ifndef AFXMLParserResponseSerializer
#define AFXMLParserResponseSerializer __NS_SYMBOL(AFXMLParserResponseSerializer)
#endif

#ifndef AVAudioPlayer
#define AVAudioPlayer __NS_SYMBOL(AVAudioPlayer)
#endif

#ifndef CustomAudioPlayer
#define CustomAudioPlayer __NS_SYMBOL(CustomAudioPlayer)
#endif

#ifndef Reachability
#define Reachability __NS_SYMBOL(Reachability)
#endif

#ifndef _AFURLSessionTaskSwizzling
#define _AFURLSessionTaskSwizzling __NS_SYMBOL(_AFURLSessionTaskSwizzling)
#endif

#ifndef ext
#define ext __NS_SYMBOL(ext)
#endif

// Functions
#ifndef AFStringFromNetworkReachabilityStatus
#define AFStringFromNetworkReachabilityStatus __NS_SYMBOL(AFStringFromNetworkReachabilityStatus)
#endif

#ifndef AFStringFromNetworkReachabilityStatus
#define AFStringFromNetworkReachabilityStatus __NS_SYMBOL(AFStringFromNetworkReachabilityStatus)
#endif

#ifndef AFQueryStringPairsFromDictionary
#define AFQueryStringPairsFromDictionary __NS_SYMBOL(AFQueryStringPairsFromDictionary)
#endif

#ifndef AFQueryStringPairsFromKeyAndValue
#define AFQueryStringPairsFromKeyAndValue __NS_SYMBOL(AFQueryStringPairsFromKeyAndValue)
#endif

#ifndef AFQueryStringPairsFromDictionary
#define AFQueryStringPairsFromDictionary __NS_SYMBOL(AFQueryStringPairsFromDictionary)
#endif

#ifndef AFQueryStringPairsFromKeyAndValue
#define AFQueryStringPairsFromKeyAndValue __NS_SYMBOL(AFQueryStringPairsFromKeyAndValue)
#endif

// Externs
#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef kReachabilityChangedNotification
#define kReachabilityChangedNotification __NS_SYMBOL(kReachabilityChangedNotification)
#endif

#ifndef AFNetworkingReachabilityDidChangeNotification
#define AFNetworkingReachabilityDidChangeNotification __NS_SYMBOL(AFNetworkingReachabilityDidChangeNotification)
#endif

#ifndef AFNetworkingReachabilityNotificationStatusItem
#define AFNetworkingReachabilityNotificationStatusItem __NS_SYMBOL(AFNetworkingReachabilityNotificationStatusItem)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFURLResponseSerializationErrorDomain
#define AFURLResponseSerializationErrorDomain __NS_SYMBOL(AFURLResponseSerializationErrorDomain)
#endif

#ifndef AFNetworkingOperationFailingURLResponseErrorKey
#define AFNetworkingOperationFailingURLResponseErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLResponseErrorKey)
#endif

#ifndef AFNetworkingOperationFailingURLResponseDataErrorKey
#define AFNetworkingOperationFailingURLResponseDataErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLResponseDataErrorKey)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFNetworkingOperationDidStartNotification
#define AFNetworkingOperationDidStartNotification __NS_SYMBOL(AFNetworkingOperationDidStartNotification)
#endif

#ifndef AFNetworkingOperationDidFinishNotification
#define AFNetworkingOperationDidFinishNotification __NS_SYMBOL(AFNetworkingOperationDidFinishNotification)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFNetworkingTaskDidResumeNotification
#define AFNetworkingTaskDidResumeNotification __NS_SYMBOL(AFNetworkingTaskDidResumeNotification)
#endif

#ifndef AFNetworkingTaskDidCompleteNotification
#define AFNetworkingTaskDidCompleteNotification __NS_SYMBOL(AFNetworkingTaskDidCompleteNotification)
#endif

#ifndef AFNetworkingTaskDidSuspendNotification
#define AFNetworkingTaskDidSuspendNotification __NS_SYMBOL(AFNetworkingTaskDidSuspendNotification)
#endif

#ifndef AFURLSessionDidInvalidateNotification
#define AFURLSessionDidInvalidateNotification __NS_SYMBOL(AFURLSessionDidInvalidateNotification)
#endif

#ifndef AFURLSessionDownloadTaskDidFailToMoveFileNotification
#define AFURLSessionDownloadTaskDidFailToMoveFileNotification __NS_SYMBOL(AFURLSessionDownloadTaskDidFailToMoveFileNotification)
#endif

#ifndef AFNetworkingTaskDidStartNotification
#define AFNetworkingTaskDidStartNotification __NS_SYMBOL(AFNetworkingTaskDidStartNotification)
#endif

#ifndef AFNetworkingTaskDidFinishNotification
#define AFNetworkingTaskDidFinishNotification __NS_SYMBOL(AFNetworkingTaskDidFinishNotification)
#endif

#ifndef AFNetworkingTaskDidCompleteSerializedResponseKey
#define AFNetworkingTaskDidCompleteSerializedResponseKey __NS_SYMBOL(AFNetworkingTaskDidCompleteSerializedResponseKey)
#endif

#ifndef AFNetworkingTaskDidCompleteResponseSerializerKey
#define AFNetworkingTaskDidCompleteResponseSerializerKey __NS_SYMBOL(AFNetworkingTaskDidCompleteResponseSerializerKey)
#endif

#ifndef AFNetworkingTaskDidCompleteResponseDataKey
#define AFNetworkingTaskDidCompleteResponseDataKey __NS_SYMBOL(AFNetworkingTaskDidCompleteResponseDataKey)
#endif

#ifndef AFNetworkingTaskDidCompleteErrorKey
#define AFNetworkingTaskDidCompleteErrorKey __NS_SYMBOL(AFNetworkingTaskDidCompleteErrorKey)
#endif

#ifndef AFNetworkingTaskDidCompleteAssetPathKey
#define AFNetworkingTaskDidCompleteAssetPathKey __NS_SYMBOL(AFNetworkingTaskDidCompleteAssetPathKey)
#endif

#ifndef AFNetworkingTaskDidFinishSerializedResponseKey
#define AFNetworkingTaskDidFinishSerializedResponseKey __NS_SYMBOL(AFNetworkingTaskDidFinishSerializedResponseKey)
#endif

#ifndef AFNetworkingTaskDidFinishResponseSerializerKey
#define AFNetworkingTaskDidFinishResponseSerializerKey __NS_SYMBOL(AFNetworkingTaskDidFinishResponseSerializerKey)
#endif

#ifndef AFNetworkingTaskDidFinishResponseDataKey
#define AFNetworkingTaskDidFinishResponseDataKey __NS_SYMBOL(AFNetworkingTaskDidFinishResponseDataKey)
#endif

#ifndef AFNetworkingTaskDidFinishErrorKey
#define AFNetworkingTaskDidFinishErrorKey __NS_SYMBOL(AFNetworkingTaskDidFinishErrorKey)
#endif

#ifndef AFNetworkingTaskDidFinishAssetPathKey
#define AFNetworkingTaskDidFinishAssetPathKey __NS_SYMBOL(AFNetworkingTaskDidFinishAssetPathKey)
#endif

#ifndef AFURLRequestSerializationErrorDomain
#define AFURLRequestSerializationErrorDomain __NS_SYMBOL(AFURLRequestSerializationErrorDomain)
#endif

#ifndef AFNetworkingOperationFailingURLRequestErrorKey
#define AFNetworkingOperationFailingURLRequestErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLRequestErrorKey)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef kAFUploadStream3GSuggestedPacketSize
#define kAFUploadStream3GSuggestedPacketSize __NS_SYMBOL(kAFUploadStream3GSuggestedPacketSize)
#endif

#ifndef kAFUploadStream3GSuggestedDelay
#define kAFUploadStream3GSuggestedDelay __NS_SYMBOL(kAFUploadStream3GSuggestedDelay)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef kReachabilityChangedNotification
#define kReachabilityChangedNotification __NS_SYMBOL(kReachabilityChangedNotification)
#endif

#ifndef AFNetworkingReachabilityDidChangeNotification
#define AFNetworkingReachabilityDidChangeNotification __NS_SYMBOL(AFNetworkingReachabilityDidChangeNotification)
#endif

#ifndef AFNetworkingReachabilityNotificationStatusItem
#define AFNetworkingReachabilityNotificationStatusItem __NS_SYMBOL(AFNetworkingReachabilityNotificationStatusItem)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFURLResponseSerializationErrorDomain
#define AFURLResponseSerializationErrorDomain __NS_SYMBOL(AFURLResponseSerializationErrorDomain)
#endif

#ifndef AFNetworkingOperationFailingURLResponseErrorKey
#define AFNetworkingOperationFailingURLResponseErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLResponseErrorKey)
#endif

#ifndef AFNetworkingOperationFailingURLResponseDataErrorKey
#define AFNetworkingOperationFailingURLResponseDataErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLResponseDataErrorKey)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFNetworkingOperationDidStartNotification
#define AFNetworkingOperationDidStartNotification __NS_SYMBOL(AFNetworkingOperationDidStartNotification)
#endif

#ifndef AFNetworkingOperationDidFinishNotification
#define AFNetworkingOperationDidFinishNotification __NS_SYMBOL(AFNetworkingOperationDidFinishNotification)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef AFNetworkingTaskDidResumeNotification
#define AFNetworkingTaskDidResumeNotification __NS_SYMBOL(AFNetworkingTaskDidResumeNotification)
#endif

#ifndef AFNetworkingTaskDidCompleteNotification
#define AFNetworkingTaskDidCompleteNotification __NS_SYMBOL(AFNetworkingTaskDidCompleteNotification)
#endif

#ifndef AFNetworkingTaskDidSuspendNotification
#define AFNetworkingTaskDidSuspendNotification __NS_SYMBOL(AFNetworkingTaskDidSuspendNotification)
#endif

#ifndef AFURLSessionDidInvalidateNotification
#define AFURLSessionDidInvalidateNotification __NS_SYMBOL(AFURLSessionDidInvalidateNotification)
#endif

#ifndef AFURLSessionDownloadTaskDidFailToMoveFileNotification
#define AFURLSessionDownloadTaskDidFailToMoveFileNotification __NS_SYMBOL(AFURLSessionDownloadTaskDidFailToMoveFileNotification)
#endif

#ifndef AFNetworkingTaskDidStartNotification
#define AFNetworkingTaskDidStartNotification __NS_SYMBOL(AFNetworkingTaskDidStartNotification)
#endif

#ifndef AFNetworkingTaskDidFinishNotification
#define AFNetworkingTaskDidFinishNotification __NS_SYMBOL(AFNetworkingTaskDidFinishNotification)
#endif

#ifndef AFNetworkingTaskDidCompleteSerializedResponseKey
#define AFNetworkingTaskDidCompleteSerializedResponseKey __NS_SYMBOL(AFNetworkingTaskDidCompleteSerializedResponseKey)
#endif

#ifndef AFNetworkingTaskDidCompleteResponseSerializerKey
#define AFNetworkingTaskDidCompleteResponseSerializerKey __NS_SYMBOL(AFNetworkingTaskDidCompleteResponseSerializerKey)
#endif

#ifndef AFNetworkingTaskDidCompleteResponseDataKey
#define AFNetworkingTaskDidCompleteResponseDataKey __NS_SYMBOL(AFNetworkingTaskDidCompleteResponseDataKey)
#endif

#ifndef AFNetworkingTaskDidCompleteErrorKey
#define AFNetworkingTaskDidCompleteErrorKey __NS_SYMBOL(AFNetworkingTaskDidCompleteErrorKey)
#endif

#ifndef AFNetworkingTaskDidCompleteAssetPathKey
#define AFNetworkingTaskDidCompleteAssetPathKey __NS_SYMBOL(AFNetworkingTaskDidCompleteAssetPathKey)
#endif

#ifndef AFNetworkingTaskDidFinishSerializedResponseKey
#define AFNetworkingTaskDidFinishSerializedResponseKey __NS_SYMBOL(AFNetworkingTaskDidFinishSerializedResponseKey)
#endif

#ifndef AFNetworkingTaskDidFinishResponseSerializerKey
#define AFNetworkingTaskDidFinishResponseSerializerKey __NS_SYMBOL(AFNetworkingTaskDidFinishResponseSerializerKey)
#endif

#ifndef AFNetworkingTaskDidFinishResponseDataKey
#define AFNetworkingTaskDidFinishResponseDataKey __NS_SYMBOL(AFNetworkingTaskDidFinishResponseDataKey)
#endif

#ifndef AFNetworkingTaskDidFinishErrorKey
#define AFNetworkingTaskDidFinishErrorKey __NS_SYMBOL(AFNetworkingTaskDidFinishErrorKey)
#endif

#ifndef AFNetworkingTaskDidFinishAssetPathKey
#define AFNetworkingTaskDidFinishAssetPathKey __NS_SYMBOL(AFNetworkingTaskDidFinishAssetPathKey)
#endif

#ifndef AFURLRequestSerializationErrorDomain
#define AFURLRequestSerializationErrorDomain __NS_SYMBOL(AFURLRequestSerializationErrorDomain)
#endif

#ifndef AFNetworkingOperationFailingURLRequestErrorKey
#define AFNetworkingOperationFailingURLRequestErrorKey __NS_SYMBOL(AFNetworkingOperationFailingURLRequestErrorKey)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

#ifndef kAFUploadStream3GSuggestedPacketSize
#define kAFUploadStream3GSuggestedPacketSize __NS_SYMBOL(kAFUploadStream3GSuggestedPacketSize)
#endif

#ifndef kAFUploadStream3GSuggestedDelay
#define kAFUploadStream3GSuggestedDelay __NS_SYMBOL(kAFUploadStream3GSuggestedDelay)
#endif

#ifndef llvm.embedded.module
#define llvm.embedded.module __NS_SYMBOL(llvm.embedded.module)
#endif

#ifndef llvm.cmdline
#define llvm.cmdline __NS_SYMBOL(llvm.cmdline)
#endif

