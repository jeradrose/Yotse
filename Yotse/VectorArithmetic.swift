import CoreGraphics

protocol VectorOperatable  {
    init(horizontal:CGFloat,vertical:CGFloat)
    var horizontal:CGFloat { get set }
    var vertical:CGFloat { get set }
}

protocol VectorArithmetic : VectorOperatable {
    var angleInRadians:CGFloat {get}
    var magnitude:CGFloat {get}
    var length:CGFloat {get}
    var lengthSquared:CGFloat {get}
    func dotProduct <T : VectorArithmetic>(vector:T) -> CGFloat
    func crossProduct <T : VectorArithmetic>(vector:T) -> CGFloat
    func distanceTo <T : VectorArithmetic>(vector:T) -> CGFloat
    var reversed:Self {get}
    var normalized:Self {get}
    func limited(scalar:CGFloat) -> Self
    func scaled(scalar:CGFloat) -> Self
    func angled(scalar:CGFloat) -> Self


}

//Since these structs already have != operator for themselves, but not against each we can't use a generic constraint

func != (lhs: CGVector , rhs: CGSize) -> Bool {
    return (lhs == rhs) == false
}
func != (lhs: CGVector , rhs: CGPoint) -> Bool {
    return (lhs == rhs) == false
}
func != (lhs: CGSize , rhs: CGVector) -> Bool {
    return (lhs == rhs) == false
}
func != (lhs: CGSize , rhs: CGPoint) -> Bool {
    return (lhs == rhs) == false
}
func != (lhs: CGPoint , rhs: CGVector) -> Bool {
    return (lhs == rhs) == false
}
func != (lhs: CGPoint , rhs: CGSize) -> Bool {
    return (lhs == rhs) == false
}

func == <T:VectorOperatable, U:VectorOperatable> (lhs:T,rhs:U) -> Bool {
    return (lhs.horizontal == rhs.horizontal && lhs.vertical == rhs.vertical)
}
//Gives ambigious operator since the struct already does compare to its own type
//func != <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
//  return (lhs == rhs) == false
//}
func <= <T:VectorOperatable, U:VectorOperatable>(lhs:T, rhs:U) -> Bool {
    return (lhs <  rhs) || (lhs == rhs)
}
func < <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
    return (lhs.horizontal <  rhs.horizontal || lhs.vertical < rhs.vertical)
}
func >= <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
    return (lhs > rhs) || ( lhs == rhs)
}
func > <T:VectorOperatable, U:VectorOperatable>(lhs: T , rhs: U) -> Bool {
    return (lhs <= rhs) == false
}

func - <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
    return T(horizontal: lhs.horizontal-rhs.horizontal, vertical: lhs.vertical-rhs.vertical)
}
func -= <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
    lhs = lhs - rhs
}

func + <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
    return T(horizontal: lhs.horizontal+rhs.horizontal, vertical: lhs.vertical+rhs.vertical)
}
func += <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
    lhs = lhs + rhs
}

func * <T:VectorOperatable, U:VectorOperatable>(lhs: T, rhs:U) -> T  {
    return T(horizontal: lhs.horizontal*rhs.horizontal, vertical: lhs.vertical*rhs.vertical);
}
func *= <T:VectorOperatable, U:VectorOperatable>(inout lhs: T, rhs:U)  {
    lhs = lhs * rhs

}

func / <T:VectorOperatable, U:VectorOperatable>(lhs:T, rhs:U) -> T  {
    return T(horizontal: lhs.horizontal/rhs.horizontal, vertical: lhs.vertical/rhs.vertical);
}
func /= <T:VectorOperatable, U:VectorOperatable>(inout lhs:T, rhs:U) -> T  {
    lhs = lhs / rhs
    return lhs
}


func / <T:VectorOperatable>(lhs:T, scalar:CGFloat) -> T  {
    return T(horizontal: lhs.horizontal/scalar, vertical: lhs.vertical/scalar);
}
func /= <T:VectorOperatable>(inout lhs:T, scalar:CGFloat) -> T  {
    lhs = lhs / scalar
    return lhs
}

func * <T:VectorOperatable>(lhs: T, scalar:CGFloat) -> T  {
    return T(horizontal: lhs.horizontal*scalar, vertical: lhs.vertical*scalar)
}
func *= <T:VectorOperatable>(inout lhs: T, value:CGFloat)   {
    lhs = lhs * value
}



struct InternalVectorArithmetic {

    static func angleInRadians  <T : VectorArithmetic>(vector:T) -> CGFloat {
        let normalizedVector = self.normalized(vector)

        let theta = atan2(normalizedVector.vertical, normalizedVector.horizontal)
        return theta + CGFloat(M_PI_2) * -1
    }

    static func magnitude <T : VectorArithmetic>(vector:T) -> CGFloat {
        return sqrt(self.lengthSquared(vector))
    }

    static func lengthSquared <T : VectorArithmetic>(vector:T) -> CGFloat {
        return ((vector.horizontal*vector.horizontal) + (vector.vertical*vector.vertical))
    }


    static func reversed <T : VectorArithmetic>(vector:T) -> T {
        return vector * -1
    }

    static func dotProduct <T : VectorOperatable, U : VectorOperatable > (vector:T, otherVector:U) -> CGFloat  {
        return (vector.horizontal*otherVector.horizontal) + (vector.vertical*otherVector.vertical)
    }

    static func crossProduct <T : VectorArithmetic, U : VectorArithmetic > (vector:T, otherVector:U) -> CGFloat  {
        let deltaAngle = sin(self.angleInRadians(vector) - self.angleInRadians(otherVector))
        return self.magnitude(vector) * self.magnitude(otherVector) * deltaAngle
    }


    static func distanceTo <T : VectorArithmetic, U : VectorArithmetic > (vector:T, otherVector:U) -> CGFloat {
        var deltaX = CGFloat.abs(vector.horizontal - otherVector.horizontal)
        var deltaY = CGFloat.abs(vector.vertical   - otherVector.vertical)
        return self.magnitude(T(horizontal: deltaX, vertical: deltaY))
    }

    static func normalized <T : VectorArithmetic>(vector:T) -> T {
        let length = self.magnitude(vector)
        var newPoint:T = vector
        if(length > 0.0) {
            newPoint /= length
        }
        return newPoint
    }

    static func limit <T : VectorArithmetic>(vector:T, scalar:CGFloat) -> T  {
        var newPoint = vector
//        if(self.magnitude(vector) > scalar) {
            newPoint = self.normalized(newPoint) * scalar
//        }
        return newPoint
    }


    static func vectorWithAngle <T:VectorArithmetic>(vector:T, scalar:CGFloat) -> T {
        let length = self.magnitude(vector)
        return T(horizontal: cos(scalar) * length, vertical: sin(scalar) * length)
    }
}


extension CGPoint: VectorArithmetic  {


    init(horizontal:CGFloat,vertical:CGFloat) {
        self.init(x: horizontal, y: vertical)
    }


    init(x:CGFloat, y:CGFloat) {
        self.init(x:Double(x), y:Double(y))
    }
    var horizontal:CGFloat {
        get { return CGFloat(self.x)      }
        set { self.x = CGFloat(newValue) }
    }
    var vertical:CGFloat {
        get {return CGFloat(self.y)       }
        set {self.y = CGFloat(newValue)  }
    }


    var angleInRadians:CGFloat { return InternalVectorArithmetic.angleInRadians(self)}
    var magnitude:CGFloat { return InternalVectorArithmetic.magnitude(self) }
    var length:CGFloat { return self.magnitude }
    var lengthSquared:CGFloat { return InternalVectorArithmetic.lengthSquared(self) }
    func dotProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
    func crossProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.crossProduct(self, otherVector: vector) }
    func distanceTo <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
    var reversed:CGPoint { return InternalVectorArithmetic.reversed(self) }
    var normalized:CGPoint { return InternalVectorArithmetic.normalized(self) }
    func limited(scalar:CGFloat) -> CGPoint { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func scaled(scalar:CGFloat) -> CGPoint { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func angled(scalar:CGFloat) -> CGPoint { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }


}


extension CGSize: VectorArithmetic   {

    init(horizontal:CGFloat,vertical:CGFloat) {
        self.init(width: horizontal, height: vertical)
    }


    init(width:CGFloat, height:CGFloat) {
        self.init(width:Double(width), height:Double(height))
    }
    var horizontal:CGFloat {
        get { return CGFloat(self.width)      }
        set { self.width = CGFloat(newValue) }
    }
    var vertical:CGFloat {
        get {return CGFloat(self.height)       }
        set {self.height = CGFloat(newValue)  }
    }



    var angleInRadians:CGFloat { return InternalVectorArithmetic.angleInRadians(self) }
    var magnitude:CGFloat { return InternalVectorArithmetic.magnitude(self) }
    var length:CGFloat { return self.magnitude }
    var lengthSquared:CGFloat { return InternalVectorArithmetic.lengthSquared(self) }
    func dotProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
    func crossProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.crossProduct(self, otherVector: vector) }

    func distanceTo <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
    var reversed:CGSize { return InternalVectorArithmetic.reversed(self) }
    var normalized:CGSize { return InternalVectorArithmetic.normalized(self) }
    func limited(scalar:CGFloat) -> CGSize { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func scaled(scalar:CGFloat) -> CGSize { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func angled(scalar:CGFloat) -> CGSize { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }


}

extension CGVector: VectorArithmetic   {

    init(horizontal:CGFloat,vertical:CGFloat) {
        self.dx = CGFloat(horizontal)
        self.dy = CGFloat(vertical)

    }


    init(_ dx:CGFloat, _ dy:CGFloat) {
        self.dx = CGFloat(dx)
        self.dy = CGFloat(dy)
    }

    var horizontal:CGFloat {
        get { return CGFloat(self.dx)      }
        set { self.dx = CGFloat(newValue) }
    }
    var vertical:CGFloat {
        get {return CGFloat(self.dy)       }
        set {self.dy = CGFloat(newValue)  }
    }


    var angleInRadians:CGFloat { return InternalVectorArithmetic.angleInRadians(self) }
    var magnitude:CGFloat { return InternalVectorArithmetic.magnitude(self) }
    var length:CGFloat { return self.magnitude }
    var lengthSquared:CGFloat { return InternalVectorArithmetic.lengthSquared(self) }
    func dotProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.dotProduct(self, otherVector: vector) }
    func crossProduct <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.crossProduct(self, otherVector: vector) }
    func distanceTo <T : VectorArithmetic> (vector:T) -> CGFloat { return InternalVectorArithmetic.distanceTo(self, otherVector: vector) }
    var reversed:CGVector { return InternalVectorArithmetic.reversed(self) }
    var normalized:CGVector { return InternalVectorArithmetic.normalized(self) }
    func limited(scalar:CGFloat) -> CGVector { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func scaled(scalar:CGFloat) -> CGVector { return InternalVectorArithmetic.limit(self, scalar: scalar) }
    func angled(scalar:CGFloat) -> CGVector { return InternalVectorArithmetic.vectorWithAngle(self, scalar: scalar) }

}