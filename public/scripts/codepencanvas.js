(function() {
  var slice = [].slice;

  (function() {
    var CodePenCanvas, chain, extend, readyFuncs;
    extend = function(base, obj) {
      var k;
      for (k in obj) {
        base[k] = obj[k];
      }
      return base;
    };
    chain = function(wrapper, host, func) {
      func.apply(host, args);
      return wrapper;
    };
    readyFuncs = [];
    CodePenCanvas = function(options) {
      var canvas, that;
      this.options = options != null ? options : {};
      that = this;
      if (this.options.el === void 0) {
        canvas = document.createElement('canvas');
        canvas.id = "screen";
        document.body.appendChild(canvas);
      } else {
        canvas = this.options.el;
      }
      this.frameSkipping = {
        allow: this.options.frameSkip || true,
        threshold: 1000
      };
      document.onreadystatechange = function() {
        if (document.readyState === "complete") {
          that.isReady = true;
          return readyFuncs.forEach(function(fn, i) {
            return fn.call(that);
          });
        }
      };
      this.isReady = false;
      this.canvas = canvas;
      this.context = this._ = canvas.getContext("2d");
      if (this.options.wrapContext !== false) {
        this.extendContext();
      }
      if (this.options.fullscreen !== false) {
        this.maximize();
      }
      this.width = canvas.width;
      this.height = canvas.height;
      return this;
    };
    CodePenCanvas.prototype.maximize = function() {
      this.canvas.width = window.innerWidth;
      this.canvas.height = window.innerHeight;
      return this;
    };
    CodePenCanvas.prototype.throttle = function(func, delay, ctx, returnValue) {
      var lastCalled, now;
      if (func == null) {
        func = null;
      }
      if (delay == null) {
        delay = 250;
      }
      if (ctx == null) {
        ctx = null;
      }
      if (returnValue == null) {
        returnValue = null;
      }
      if (!func) {
        return;
      }
      lastCalled = performance.now();
      now = null;
      return function() {
        var args;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        if ((lastCalled + delay) > (now = performance.now())) {
          return returnValue;
        }
        lastCalled = now;
        return func.apply(ctx, args);
      };
    };
    CodePenCanvas.prototype.chain = function(func, hasReturnValue) {
      var source;
      source = this;
      if (hasReturnValue) {
        return function() {
          var args;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          return func.apply(source.context, args);
        };
      } else {
        return function() {
          var args;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          func.apply(source.context, args);
          return source;
        };
      }
    };
    CodePenCanvas.prototype.chainingExceptions = {
      "getImageData": "getImageData",
      "createImageData": "createImageData"
    };
    CodePenCanvas.prototype.extendContext = function() {
      var ctx, exceptionName, hasReturn, key, makeSetGetFunction, that, value;
      that = this;
      makeSetGetFunction = function(keyname) {
        return function(value) {
          if (value === void 0) {
            return that.context[keyname];
          }
          that.context[keyname] = value;
          return that;
        };
      };
      ctx = this.context;
      if (!ctx) {
        throw new Error("Illegal Invocation: extendContext. Call after instantiation.");
      }
      for (key in ctx) {
        value = ctx[key];
        if (typeof value === "function") {
          hasReturn = false;
          for (exceptionName in this.chainingExceptions) {
            if (key === exceptionName) {
              hasReturn = true;
            }
          }
          this[key] = this.chain(value, hasReturn);
        } else {
          if (key !== "canvas") {
            this[key] = makeSetGetFunction(key);
          }
        }
      }
      return this;
    };
    CodePenCanvas.prototype.ready = function(fn) {
      if (this.isReady) {
        fn.call(this);
      } else {
        readyFuncs.push(fn);
      }
      return this;
    };
    CodePenCanvas.prototype.start = function() {
      var frameSkippingThreshold, now, prerender, renderLoop, skipFrame, start, time;
      now = function() {
        return Date.now();
      };
      frameSkippingThreshold = this.frameSkipping.threshold;
      if (this.frameSkipping.allow) {
        skipFrame = function(dt) {
          return dt >= frameSkippingThreshold;
        };
      } else {
        skipFrame = function(dt) {
          return false;
        };
      }
      start = now();
      time = {
        'elapsed': 0,
        'lastCalled': now(),
        'now': now(),
        'start': now(),
        'delta': null,
        'id': null
      };
      prerender = function(e) {
        var _now;
        if (this.running !== true) {
          return;
        }
        _now = now();
        time.elapsed = _now - time.start;
        time.now = _now;
        time.delta = _now - time.lastCalled;
        if (skipFrame(time.delta)) {
          time.elapsed -= time.delta;
        } else {
          this.render.call(this, time);
          time.lastCalled = _now;
        }
        time.id = window.requestAnimationFrame(renderLoop);
        return this.__frame = time.id;
      };
      renderLoop = prerender.bind(this);
      this.running = true;
      time.id = window.requestAnimationFrame(renderLoop);
      return this;
    };
    CodePenCanvas.prototype.stop = function() {
      window.cancelAnimationFrame(this.__frame);
      this.running = false;
      return this;
    };
    CodePenCanvas.prototype.render = function(render) {
      if (typeof render === "function") {
        this.render = render;
      } else {
        throw new Error("Render function is not set.");
      }
      return this;
    };
    CodePenCanvas.prototype.polygon = function(matrix) {
      var elements, i, j, ref;
      if (matrix.length !== 2) {
        return this;
      }
      elements = {
        x: matrix[0],
        y: matrix[1]
      };
      if (elements.x.length !== elements.y.length) {
        throw new Error("Polygon was passed an Incompatible Matrix");
        return this;
      }
      console.log(elements);
      this.beginPath();
      this.moveTo(elements.x[0], elements.y[0]);
      for (i = j = 0, ref = elements.x.length; 0 <= ref ? j < ref : j > ref; i = 0 <= ref ? ++j : --j) {
        this.lineTo(elements.x[i], elements.y[i]);
      }
      return this.closePath();
    };
    CodePenCanvas.prototype.triangle = function(pt1, pt2, pt3) {
      if (pt1 == null) {
        pt1 = {
          x: 0,
          y: 0
        };
      }
      if (pt2 == null) {
        pt2 = {
          x: 50,
          y: 100
        };
      }
      if (pt3 == null) {
        pt3 = {
          x: 100,
          y: 50
        };
      }
      if (typeof pt1 === "object" && pt1.length !== void 0) {
        return this.polygon(pt1);
      }
      this.beginPath();
      this.moveTo(pt1.x, pt1.y);
      this.lineTo(pt2.x, pt2.y);
      this.lineTo(pt3.x, pt3.y);
      this.closePath();
      return this;
    };
    CodePenCanvas.prototype.clear = function(fill) {
      if (fill == null) {
        fill = "#fff";
      }
      return this.fillStyle(fill).fillRect(0, 0, this.width, this.height);
    };
    return window.CodePenCanvas = CodePenCanvas;

    /*canvas = new CodePenCanvas()
    canvas.render (time) ->
      console.log time.elapsed
    canvas.ready () ->
      canvas.start()
     */
  })();

}).call(this);
