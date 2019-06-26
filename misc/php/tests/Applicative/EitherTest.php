<?php
declare(strict_types=1);


namespace Tests\Applicative;

use App\Monad\Either\Right;
use App\Monad\Either\Either;
use App\Monad\Either\Left;
use App\Utils;
use PHPUnit\Framework\TestCase;
use Tests\LambdasAsMethods;

/**
 * Applicatives
 * class (Functor f) => Applicative f where
 *      pure :: a -> f a
 *      (<*>) :: f (a -> b) -> f a -> f b         (called apply)
 *
 * Applicative laws
 * Identity
 * applying the pure id morphism does nothing, exactly like with the plain id function
 *      pure id <*> f = f
 *
 * Homomorphism
 * applying a "pure" function to a "pure" value is the same as applying the function to the value in the normal way and then using pure on the result. In a sense, that means pure preserves function application
 *      pure f <*> pure x = pure (f x)
 *
 * Interchange
 * applying a morphism to a "pure" value `pure y` is the same as applying pure ($ y) to the morphism
 *      u <*> pure v = pure ($ v) <*> u
 *
 * Composition
 * `pure (.)` composes morphisms similarly to how `(.)` composes functions: applying the composed morphism `pure (.) <*> u <*> v` to w gives the same result as applying u to the result of applying v to w
 *      pure (.) <*> u <*> v <*> w = u <*> (v <*> w)
 *
 * @package App\Applicative
 */
class EitherTest extends TestCase
{
    use LambdasAsMethods;
    
    /** @var callable */
    private $double;
    
    /** @var callable */
    private $add1;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->double = function (int $i): int {
            return $i * 2;
        };
        $this->add1 = function (int $i): int {
            return $i + 1;
        };
    }
    
    /**
     * pure f <*> x = fmap f x
     */
    public function testFmapLawWithRight()
    {
        $either = new Right(123);
        
        $this->assertEquals(
            Either::fmap($this->double, $either),
            Either::apply(Either::pure($this->double), $either)
        );
    }
    
    /**
     * pure f <*> x = fmap f x
     */
    public function testFmapLawWithLeft()
    {
        $either = new Left(456);
        
        $this->assertEquals(
            Either::fmap($this->double, $either),
            Either::apply(Either::pure($this->double), $either)
        );
    }
    
    /**
     * pure id <*> f = f
     */
    public function testIDLawWithRight()
    {
        $id = function ($x) {
            return $x;
        };
        $either = new Right(123);
        
        $this->assertEquals(
            $either,
            Either::apply(Either::pure($id), $either)
        );
    }
    
    /**
     * pure id <*> f = f
     */
    public function testIDLawWithLeft()
    {
        $id = function ($x) {
            return $x;
        };
        $either = new Left(456);
    
        $this->assertEquals(
            $either,
            Either::apply(Either::pure($id), $either)
        );
    }
    
    /**
     * pure f <*> pure x = pure (f x)
     */
    public function testHomomorphismLaw()
    {
        $applicative = Either::pure($this->double);
        $applicative2 = Either::pure(123);
    
        $this->assertEquals(
            Either::pure($this->double(123)),
            Either::apply($applicative, $applicative2)
        );
    }
    
    /**
     * applying a morphism `u` to a "pure" value `pure v` is the same as applying pure ($ v) to the morphism
     * u <*> pure v = pure ($ v) <*> u
     */
    public function testInterchangeLaw()
    {
        $morphism = Either::pure($this->double);
        $value = 123;
        $pureValue = Either::pure($value);
        
        $this->assertEquals(
            Either::apply($morphism, $pureValue),
            Either::apply(
                Either::pure(function ($f) use ($value) {
                    return $f($value);
                }),
                $morphism
            )
        );
    }
    
    /**
     * `pure (.)` composes morphisms similarly to how `(.)` composes functions: applying the composed morphism `pure (.) <*> u <*> v` to w gives the same result as applying u to the result of applying v to w
     *      pure (.) <*> u <*> v <*> w = u <*> (v <*> w)
     *
     * <*> is left-associative, which means that pure (+) <*> Right 3 <*> Right 5 is the same as (pure (+) <*> Right 3) <*> Right 5
     * pure (.) <*> u <*> v <*> w
     * (pure (.) <*> u) <*> v <*> w
     * ((pure (.) <*> u) <*> v) <*> w
     */
//    public function testCompositionLaw()
//    {
//        $u = new Right($this->double);
//        $v = new Right($this->add1);
//        $w = new Right(3);
//
//        $composeAppliedToU = Either::apply(
//            Either::pure("App\Utils::compose"),
//            $u
//        );
//        $composeAndUAppliedToV = Either::apply(
//            $composeAppliedToU,
//            $v
//        );
//        $lhs = Either::apply(
//            $composeAndUAppliedToV,
//            $w
//        );
//
//        $rhs = Either::apply(
//            Either::apply(
//                $v,
//                $w
//            ),
//            $u
//        );
//
//        $this->assertEquals($lhs, $rhs);
//    }
    
}