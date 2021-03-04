//
//  OrderedDictionary.swift
//  OrderedDictionary
//
//  Created by Ryan Nair on 08/20/2020
//  Copyright 2020 Ryan Nair. All rights reserved.
//
//  This software is provided 'as-is', without any express or implied
//  warranty. In no event will the authors be held liable for any damages
//  arising from the use of this software. Permission is granted to anyone to
//  use this software for any purpose, including commercial applications, and to
//  alter it and redistribute it freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//     claim that you wrote the original software. If you use this software
//     in a product, an acknowledgment in the product documentation would be
//     appreciated but is not required.
//  2. Altered source versions must be plainly marked as such, and must not be
//     misrepresented as being the original software.
//  3. This notice may not be removed or altered from any source
//     distribution.
//

import Foundation

@objc(OrderedDictionary) public class OrderedDictionary: NSMutableDictionary {
	
    private var dictionary: NSMutableDictionary!
    private var array: NSMutableArray!

	override init() {
		super.init()
	}

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    public override init(capacity: Int) {
        super.init()
        dictionary = NSMutableDictionary(capacity: capacity)
        array = NSMutableArray(capacity: capacity)
    }

    public override func setObject(_ anObject: Any, forKey aKey: NSCopying) {
		if dictionary[aKey] == nil {
			array.add(aKey)
		}
         dictionary[aKey] = anObject
    }

    public override func removeObject(forKey aKey: Any) {
		dictionary.removeObject(forKey: aKey)
		array.remove(aKey)
    }

    public override var count: Int {
        return dictionary.count
    }

    public override func object(forKey aKey: Any) -> Any? {
        return dictionary[aKey]
    }

    public override func keyEnumerator() -> NSEnumerator {
        return array.objectEnumerator()
    }
}