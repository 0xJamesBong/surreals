## The Surreals

This is a smart contract of NFTs representing a Zermelo construction of the Naturals.

The Naturals are represented as strings of curly brackets.

```
    0 = {} = emptyset
    1 = {0} = {{}}
    2 = {1} = {{{}}}
```

And so on.

This is slightly different from the more familiar Zermelo / Von Neuman Ordinal construction of the Naturals where

```
    0 = {} = emptyset
    1 = {0} = {emptyset}
    2 = {0,1} = {{}, {{}}}
```

It doesn't really matter as the two constructions are isomorphic.

## Idea of the project

Numbers are the most well studied class metaphysical objects known to man. All other number systems can be constructed from the Naturals: 0, 1, 2, 3 ... and so on.

## Use

There's probably a quote from Pythagoras or Euclid apt for this ocassion. Alas, I cannot recall.

## Mathematical Structure

The completion of the number system here is the naturals N (including zero), but not the integers (Z).
The number system here is equipped with addition, subtraction, and multiplication. It is closed under addition and multiplication, but not subtraction (there are no negative integers here). Nor is division equipped.

To close this set of numbers under subtraction, which would make this into a Group under addition, we will need to construct the integers. This could be done by defining an integer to be an ordered pair <a,b> of natural numbers, where <a,b> corresponds to the difference a-b. Where a-b is undefined under the subtraction operation as defined in our vanilla version of the Naturals, we shall assign such a-b to be a negative integer. With this, the negatives will be born.

To close this set of numbers under multiplication, we will have to define inverses of multiplication, which requires us to define fractions. This essentially means we will have to extend from the integers into the Rationals (Q). We can define a rational to be an ordered pair <c,d> where d is not equal to zero. Further rules on their operations can be defined and from those rules we can obtain the closure under multiplication.

Naturally, having arrived at the rationals, we would want to advance to the Reals. There are many ways to construct the Real numbers, but not all of them will be continuous with the construction methodology we have laid down so far. For example, axiomatic constructions will probably not be plausible. Cauchy sequences will also not be plausible, as it is not clear how the limit of a sequence can be represented or computed on a smart contract level. In the opinion of the writer, Dedekind Cuts seem the most promising.

At this point, with the construction of the Reals, we will be able to start constructing the Complex Numbers. Furthermore, if indeed the Dedekind construction of the Reals is possible, it might be possible to construct the Surreals, using Conway's notation, which is eerily similar to Dedekind cuts.
