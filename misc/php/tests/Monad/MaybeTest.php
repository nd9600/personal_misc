<?php
declare(strict_types=1);


namespace Tests\Monad;


use App\Monad\Maybe\Just;
use App\Monad\Maybe\Maybe;
use App\Monad\Maybe\Nothing;
use App\Monad\Monad;
use PHPUnit\Framework\TestCase;
use Tests\LambdasAsMethods;

/**
 * Functors
 * fmap  :: (Functor f)     =>   (a -> b) -> f a -> f b
 *
 *
 *
 * Applicatives
 * (<*>) :: (Applicative f) => f (a -> b) -> f a -> f b
 *
 *
 *
 * Monads
 * return :: a -> m a
 * (>>=)  :: (Monad m)       => m a -> (a -> m b) -> m b
 *
 * Monad laws
 * Left identity
 *      f :: (a -> m b),
 *      return x >>= f    === f x
 *
 * Right identity
 *      m >>= return      === m
 *
 * Associativity
 *      f :: (a -> m b),
 *      g :: (c -> m d),
 *      (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
 *
 */


final class MaybeTest extends TestCase
{
    use LambdasAsMethods;
    
    /** @var callable */
    private $double;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->double = function (int $i): Maybe {
            return new Just($i * 2);
        };
    }
    
    
    /**
     * f :: (a -> m b),
     * return x >>= f    === f x
     */
    public function testLeftIdentityLaw()
    {
        $this->assertEquals(
            $this->double(1),
            Maybe::bind(
                Maybe::return(1),
                $this->double
            )
        );
    }
    
    /**
     * m >>= return      === m
     */
    public function testRightIdentityLawWithJust()
    {
        $m = new Just(123);
        $this->assertEquals(
            $m,
            Maybe::bind(
                $m,
                Maybe::return
            )
        );
    }
    
    /**
     * m >>= return      === m
     */
    public function testRightIdentityLawWithNothing()
    {
        $m = new Nothing();
        $this->assertEquals(
            $m,
            Maybe::bind(
                $m,
                Maybe::return
            )
        );
    }
    
    /**
     *  f :: (a -> m b),
     *  g :: (c -> m d),
     * (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
     */
    public function testAssociativityLawWithJustInput()
    {
        $g = function(int $i): Maybe {
            return new Just($i + 1);
        };
        
        $m = new Just(123);
        
        $lhs = Maybe::bind(
            Maybe::bind($m, $this->double),
            $g
        );
        
        $rhs = Maybe::bind(
            $m,
            function ($x) use ($g) {
                return Maybe::bind(
                    $this->double($x),
                    $g
                );
            }
        );
        
        $this->assertEquals($lhs, $rhs);
    }
    
    /**
     *  f :: (a -> m b),
     *  g :: (c -> m d),
     * (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
     */
    public function testAssociativityLawWithNothingInput()
    {
        $g = function (int $i): Maybe {
            return new Just($i + 1);
        };
        
        $m = new Nothing();
        
        $lhs = Maybe::bind(
            Maybe::bind($m, $this->double),
            $g
        );
        
        $rhs = Maybe::bind(
            $m,
            function ($x) use ($g) {
                return Maybe::bind(
                    $this->double($x),
                    $g
                );
            }
        );
        
        $this->assertEquals($lhs, $rhs);
    }
    
    /**
     *  f :: (a -> m b),
     *  g :: (c -> m d),
     * (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
     */
    public function testAssociativityLawWithNothingInsertedHalfwayThrough()
    {
        $g = function (int $i): Maybe {
            return new Nothing();
        };
    
        $m = new Just(123);
        
        $lhs = Maybe::bind(
            Maybe::bind($m, $this->double),
            $g
        );
        
        $rhs = Maybe::bind(
            $m,
            function ($x) use ($g) {
                return Maybe::bind(
                    $this->double($x),
                    $g
                );
            }
        );
        
        $this->assertEquals($lhs, $rhs);
    }
    
    public function testSingleBind()
    {
        $m = Maybe::return(123);
        
        /** @var Just $result */
        $result = Maybe::bind($m, $this->double);
        $this->assertEquals(246, $result->getData());
    }
    
    public function testMultipleBinds()
    {
        $add1 = function (int $i): Maybe {
            return new Just($i + 1);
        };
        
        $m = new Just(123);
    
        /** @var Just $result */
        $result = Maybe::bind(
            Maybe::bind($m, $this->double),
            $add1
        );
        
        
        $this->assertEquals(247, $result->getData());
    }
    
    public function testMultipleBindsWithClassMethod()
    {
        $add1 = function (int $i): Maybe {
            return new Just($i + 1);
        };
        
        $m = new Just(123);
        
        /** @var Just $result */
        $result = $m
            ->bindClass($this->double)
            ->bindClass($add1);
        
        $this->assertEquals(247, $result->getData());
    }
    
    public function testMultipleBindsWithCompose()
    {
        $m = new Just(123);
    
        /** @var Just $result2 */
        $result2 = Maybe::composeWithBinds(
            $m,
            function (int $i): Maybe {
                return new Just($i * 2);
            },
            function (int $i): Maybe {
                return new Just($i + 1);
            }
        );
        $this->assertEquals(247, $result2->getData());
    }
    
    public function testGetOrElseWithJust()
    {
        $m = Maybe::return(123);
        
        /** @var Just $result */
        $result = $m->getOrElse(456);
        $this->assertEquals(123, $result->getData());
    }
    
    public function testGetOrElseWithNothing()
    {
        $m = new Nothing();
        
        /** @var Just $result */
        $result = $m->getOrElse(456);
        $this->assertEquals(456, $result->getData());
    }
    
    public function testFoldWithJust()
    {
        $m = Maybe::return(123);
        
        /** @var Just $result */
        $result = $m->fold(1, $this->double);
        $this->assertEquals(246, $result->getData());
    }
    
    public function testFoldWithNothing()
    {
        $m = new Nothing();
        
        /** @var Just $result */
        $result = $m->fold(1, $this->double);
        $this->assertEquals(1, $result->getData());
    }
}