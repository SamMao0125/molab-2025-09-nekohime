import Foundation

func load(_ file: String) -> String {
    guard let path = Bundle.main.path(forResource: file, ofType: nil) else {
        return "❌ File not found: \(file)"
    }
    
    guard let str = try? String(contentsOfFile: path, encoding: .utf8) else {
        return "❌ Could not read file: \(file)"
    }
    
    return str
}

print("Attempting to load files:")
print(load("sitting_cat.txt"))
print()
print(load("sleeping_cat.txt"))
print()
print(load("playful_cat.txt"))
print()


print("Simple cat face:")
print("""
       /\\_/\\  
      ( o.o ) 
       > ^ <
""")

print()
print("Happy cat:")
print("""
   /\\_/\\  
  ( ^.^ ) 
   > ^ <
""")

print()
print("Grumpy cat:")
print("""
    /\\_/\\
   ( -.- )
    > v <
""")

print()
print("Fat cat:")
print("""
     /\\_____/\\
    (  o   o  )
     )       (
    (    ^    )
     \\  ---  /
      \\_____/
""")

print()
print("Sitting cat (full body):")
print("""
      |\\      _,,,---,,_
ZZZzz /,`.-'`'    -.  ;-;;,_
     |,4-  ) )-,_. ,\\ (  `'-'
    '---''(_/--'  `-'\\_)
""")

print()
print("Playful kitten:")
print("""
       /|       /|  
      ( :v:  )  ( :v:  )
       |(_)|    |(_)|
""")
