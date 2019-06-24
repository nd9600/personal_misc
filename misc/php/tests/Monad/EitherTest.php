<?php
declare(strict_types=1);


namespace Tests\Monad;


use App\Monad\Either\Either;
use App\Monad\Either\Left;
use App\Monad\Either\Right;
use Exception;
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


final class EitherTest extends TestCase
{
    use LambdasAsMethods;
    
    /** @var callable */
    private $double;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->double = function (int $i): Either {
            return new Right($i * 2);
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
            Either::bind(
                Either::return(1),
                $this->double
            )
        );
    }
    
    /**
     * m >>= return      === m
     */
    public function testRightIdentityLawWithRight()
    {
        $m = new Right(123);
        $this->assertEquals(
            $m,
            Either::bind(
                $m,
                Either::return
            )
        );
    }
    
    /**
     * m >>= return      === m
     */
    public function testRightIdentityLawWithLeft()
    {
        $m = new Left(123);
        $this->assertEquals(
            $m,
            Either::bind(
                $m,
                Either::return
            )
        );
    }
    
    /**
     *  f :: (a -> m b),
     *  g :: (c -> m d),
     * (m >>= f) >>= g   === m >>= (\x -> f x >>= g)
     */
    public function testAssociativityLawWithRightInput()
    {
        $g = function (int $i): Either {
            return new Right($i + 1);
        };
        
        $m = new Right(123);
        
        $lhs = Either::bind(
            Either::bind($m, $this->double),
            $g
        );
        
        $rhs = Either::bind(
            $m,
            function ($x) use ($g) {
                return Either::bind(
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
    public function testAssociativityLawWithLeftInput()
    {
        $g = function (int $i): Either {
            return new Right($i + 1);
        };
        
        $m = new Left(123);
        
        $lhs = Either::bind(
            Either::bind($m, $this->double),
            $g
        );
        
        $rhs = Either::bind(
            $m,
            function ($x) use ($g) {
                return Either::bind(
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
    public function testAssociativityLawWithLeftInsertedHalfwayThrough()
    {
        $g = function (int $i): Either {
            return new Left(456);
        };
        
        $m = new Right(123);
        
        $lhs = Either::bind(
            Either::bind($m, $this->double),
            $g
        );
        
        $rhs = Either::bind(
            $m,
            function ($x) use ($g) {
                return Either::bind(
                    $this->double($x),
                    $g
                );
            }
        );
        
        $this->assertEquals($lhs, $rhs);
    }
    
    public function testTryCatchWhenItThrows()
    {
        $f = function () {
            throw new Exception("FIRE!!");
        };
        $g = function (Exception $exception) {
            return $exception->getMessage();
        };
        
        $result = Either::tryCatch($f, $g);
        
        $this->assertEquals("FIRE!!", $result->getData());
    }
    
    public function testTryCatchWhenItDoesntThrow()
    {
        $f = function () {
            return "success";
        };
        $g = function (Exception $exception) {
            return $exception->getMessage();
        };
        
        $result = Either::tryCatch($f, $g);
        
        $this->assertEquals("success", $result->getData());
    }
    
}