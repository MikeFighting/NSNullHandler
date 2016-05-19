//
//  NullSafe.m
//
//  Version 1.2.1
//
//  Created by Nick Lockwood on 19/12/2012.
//  Copyright 2012 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/NullSafe
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import <objc/runtime.h>
#import <Foundation/Foundation.h>


#ifndef NULLSAFE_ENABLED
#define NULLSAFE_ENABLED 1
#endif


#pragma GCC diagnostic ignored "-Wgnu-conditional-omitted-operand"


@implementation NSNull (NullSafe)

#if NULLSAFE_ENABLED

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector
{
    @synchronized([self class])
    {
        // 寻找 method signature
        NSMethodSignature *signature = [super methodSignatureForSelector:selector];
        if (!signature)
        {
             //改消息不能被NSNull处理，所以我们要寻找其它的可以处理的类
            static NSMutableSet *classList = nil;
            static NSMutableDictionary *signatureCache = nil;
            if (signatureCache == nil)
            {
                classList = [[NSMutableSet alloc] init];
                signatureCache = [[NSMutableDictionary alloc] init];// 缓存这个找到的 method signature，以便下次寻找

                // 获取项目中的所有类，并且去除有子类的类。
                // objc_getClassList：这个方法会将所有的类缓存，以及这些类的数量。我们需要提供一块足够大得缓存来存储它们，所以我们必须调用这个函数两次。第一次来判断buffer的大小，第二次来填充这个buffer
                int numClasses = objc_getClassList(NULL, 0);
                Class *classes = (Class *)malloc(sizeof(Class) * (unsigned long)numClasses);
                numClasses = objc_getClassList(classes, numClasses);
                
                //add to list for checking
                // A -> B -> C -> NSObject
                // D -> NSObject
                // B->C->NSObject

                NSMutableSet *excluded = [NSMutableSet set];
                for (int i = 0; i < numClasses; i++)
                {
                    //determine if class has a superclass
                    Class someClass = classes[i];
                    
                    // 筛选出其中含有子类的类，加入:excluded中
                    Class superclass = class_getSuperclass(someClass);
                    while (superclass) // 一个类存在父类
                    {
                        if (superclass == [NSObject class])  // 如果父类是NSObject,则跳出循环，并且加入classList
                        {
                            // 将系统中用到的所有类都加到了ClassList中
                            [classList addObject:someClass];
                            break;
                        }
                        
                        //父类不是NSObject,将其父类添加到excluded
                        [excluded addObject:superclass];
                         superclass = class_getSuperclass(superclass);
                    }
                }

                // 删除所有含有子类的类 例如：在此之前是有ZHSubObject的，移除之后只剩下了ZHSubSubObject
                for (Class someClass in excluded)
                {
                    [classList removeObject:someClass];
                }

                //释放内存
                free(classes);
            }
            
            // 首先检测缓存是否有这个实现
            NSString *selectorString = NSStringFromSelector(selector);
            signature = signatureCache[selectorString];
            if (!signature)
            {
                //找到方法的实现
                for (Class someClass in classList)
                {
                    if ([someClass instancesRespondToSelector:selector])
                    {
                        signature = [someClass instanceMethodSignatureForSelector:selector];
                        break;
                    }
                }
                
                //缓存以备下次使用
                signatureCache[selectorString] = signature ?: [NSNull null];
            }
            else if ([signature isKindOfClass:[NSNull class]])
            {
                signature = nil;
            }
        }
        return signature;
    }
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    // 让nil来处理这个invocation
    [invocation invokeWithTarget:nil];
}

#endif

@end
