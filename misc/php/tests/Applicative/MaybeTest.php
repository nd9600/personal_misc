<?php
declare(strict_types=1);


namespace Tests\Applicative;

use App\Monad\Maybe\Just;
use App\Monad\Maybe\Maybe;
use App\Monad\Maybe\Nothing;
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
class MaybeTest extends TestCase
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
    public function testFmapLawWithJust()
    {
        $maybe = new Just(123);
        
        $this->assertEquals(
            Maybe::fmap($this->double, $maybe),
            Maybe::apply(Maybe::pure($this->double), $maybe)
        );
    }
    
    /**
     * pure f <*> x = fmap f x
     */
    public function testFmapLawWithNothing()
    {
        $maybe = new Nothing();
        
        $this->assertEquals(
            Maybe::fmap($this->double, $maybe),
            Maybe::apply(Maybe::pure($this->double), $maybe)
        );
    }
    
    /**
     * pure id <*> f = f
     */
    public function testIDLawWithJust()
    {
        $id = function ($x) {
            return $x;
        };
        $maybe = new Just(123);
        
        $this->assertEquals(
            $maybe,
            Maybe::apply(Maybe::pure($id), $maybe)
        );
    }
    
    /**
     * pure id <*> f = f
     */
    public function testIDLawWithNothing()
    {
        $id = function ($x) {
            return $x;
        };
        $maybe = new Nothing();
    
        $this->assertEquals(
            $maybe,
            Maybe::apply(Maybe::pure($id), $maybe)
        );
    }
    
    /**
     * pure f <*> pure x = pure (f x)
     */
    public function testHomomorphismLaw()
    {
        $applicative = Maybe::pure($this->double);
        $applicative2 = Maybe::pure(123);
    
        $this->assertEquals(
            Maybe::pure($this->double(123)),
            Maybe::apply($applicative, $applicative2)
        );
    }
    
    /**
     * applying a morphism `u` to a "pure" value `pure v` is the same as applying pure ($ v) to the morphism
     * u <*> pure v = pure ($ v) <*> u
     */
    public function testInterchangeLaw()
    {
        $morphism = Maybe::pure($this->double);
        $value = 123;
        $pureValue = Maybe::pure($value);
        
        $this->assertEquals(
            Maybe::apply($morphism, $pureValue),
            Maybe::apply(
                Maybe::pure(function ($f) use ($value) {
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
     * <*> is left-associative, which means that pure (+) <*> Just 3 <*> Just 5 is the same as (pure (+) <*> Just 3) <*> Just 5
     * pure (.) <*> u <*> v <*> w
     * (pure (.) <*> u) <*> v <*> w
     * ((pure (.) <*> u) <*> v) <*> w
     */
    public function testCompositionLaw()
    {
        $u = new Just($this->double);
        $v = new Just($this->add1);
        $w = new Just(3);
    
        $composeAppliedToU = Maybe::apply(
            Maybe::pure("App\Utils::compose"),
            $u
        );
        $composeAndUAppliedToV = Maybe::apply(
            $composeAppliedToU,
            $v
        );
        $lhs = Maybe::apply(
            $composeAndUAppliedToV,
            $w
        );
        
        $rhs = Maybe::apply(
            Maybe::apply(
                $v,
                $w
            ),
            $u
        );
        
        $this->assertEquals($lhs, $rhs);
    }
    
}