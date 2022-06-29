# hiedemo

Demonstrates that `HieAST` is missing types for record dot syntax, but shows that the type info is available in `CoreProgram`.

Type `cabal run` with GHC 9.2.x to get the printed HieAST and printed CoreProgram.

## Relevant CoreProgram output

```
 y = ++
       @Char
       (getField
          @Symbol
          @"a"
          @MyRecord
          @[Char]
          ($sel:a:MyRecord
           `cast` (Sym (N:HasField[0]
                            <Symbol>_N <"a">_N) <MyRecord>_N <[Char]>_N
                   :: Coercible (MyRecord -> [Char]) (HasField "a" MyRecord [Char])))
          x)
       (show
          @Integer
          $fShowInteger
          (getField
             @Symbol
             @"b"
             @MyRecord
             @Integer
             ($sel:b:MyRecord
              `cast` (Sym (N:HasField[0]
                               <Symbol>_N <"b">_N) <MyRecord>_N <Integer>_N
                      :: Coercible
                           (MyRecord -> Integer) (HasField "b" MyRecord Integer)))
             x)),
```

Notice that the [Char] and Integer types are readily apparent here.

## Relevant HieAST output

```
  Node@app/Test.hs:14:1-19: Source: From source
                            {(annotations: {(AbsBinds, HsBindLR), (FunBind, HsBindLR),
                                            (Match, Match)}), 
                             (types: [3]), 
                             (identifier info: {(name $dHasField,  Details:  Just 63 {evidence variable bound by a let, depending on: []
                                                                                      with scope: LocalScope app/Test.hs:14:1-19
                                                                                      bound at: app/Test.hs:14:1-19}), 
                                                (name $dShow,  Details:  Just 53 {evidence variable bound by a let, depending on: [$fShowInteger]
                                                                                  with scope: LocalScope app/Test.hs:14:1-19
                                                                                  bound at: app/Test.hs:14:1-19}), 
                                                (name $dHasField,  Details:  Just 65 {evidence variable bound by a let, depending on: []
                                                                                      with scope: LocalScope app/Test.hs:14:1-19
                                                                                      bound at: app/Test.hs:14:1-19}), 
                                                (name $fShowInteger,  Details:  Just 53 {usage of evidence variable})})}
                            
    Node@app/Test.hs:14:1: Source: From source
                           {(annotations: {}),  (types: []), 
                            (identifier info: {(name y,  Details:  Just 3 {LHS of a match group,
                                                                           regular value bound with scope: ModuleScope bound at: app/Test.hs:14:1-19})})}
                           
    Node@app/Test.hs:14:3-19: Source: From source
                              {(annotations: {(GRHS, GRHS)}),  (types: []), 
                               (identifier info: {})}
                              
      Node@app/Test.hs:14:5-19: Source: From source
                                {(annotations: {(HsApp, HsExpr), (XExpr, HsExpr),
                                                (OpApp, HsExpr)}), 
                                 (types: []),  (identifier info: {})}
                                
        Node@app/Test.hs:14:5-7: Source: From source
                                 {(annotations: {(HsApp, HsExpr), (XExpr, HsExpr)}),  (types: []), 
                                  (identifier info: {})}
                                 
          Node@app/Test.hs:14:5: Source: From source
                                 {(annotations: {(HsVar, HsExpr)}),  (types: [0]), 
                                  (identifier info: {(name x,  Details:  Just 0 {usage})})}
                                 
        Node@app/Test.hs:14:9-10: Source: From source
                                  {(annotations: {(HsVar, HsExpr), (XExpr, HsExpr)}), 
                                   (types: [66, 71]), 
                                   (identifier info: {(name ++,  Details:  Just 71 {usage})})}
                                  
        Node@app/Test.hs:14:12-19: Source: From source
                                   {(annotations: {(HsApp, HsExpr)}),  (types: []), 
                                    (identifier info: {})}
                                   
          Node@app/Test.hs:14:12-15: Source: From source
                                     {(annotations: {(HsVar, HsExpr), (XExpr, HsExpr)}), 
                                      (types: [72, 74]), 
                                      (identifier info: {(name $dShow,  Details:  Just 53 {usage of evidence variable}), 
                                                         (name show,  Details:  Just 74 {usage})})}
                                     
          Node@app/Test.hs:14:17-19: Source: From source
                                     {(annotations: {(HsApp, HsExpr), (XExpr, HsExpr)}), 
                                      (types: []),  (identifier info: {})}
                                     
            Node@app/Test.hs:14:17: Source: From source
                                    {(annotations: {(HsVar, HsExpr)}),  (types: [0]), 
                                     (identifier info: {(name x,  Details:  Just 0 {usage})})}
```

Notice that the nodes corresponding to the usage of record dot syntax (Test.hs:14:5-7 and Test.hs:14:17-19) have no types associated with them.
