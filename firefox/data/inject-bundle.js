(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var html2Arr, inspectInvalidNode, isValidNode, makeFunctionFromReplacementObject, replaceAllFromJson, watchNodesAndReplaceText;

html2Arr = function(htmlCollection) {
  return Array.prototype.slice.call(htmlCollection, 0);
};

inspectInvalidNode = function(node) {
  return !node || node.tagName.toUpperCase() === 'input' || (typeof node.getAttribute === "function" ? node.getAttribute('contenteditable' || (typeof node.getAttribute === "function" ? node.getAttribute('role' === 'textbox') : void 0)) : void 0);
};

isValidNode = function(node) {
  if (node === document || node.parentNode === document) {
    return false;
  }
  while (node.parentNode !== document) {
    if (inspectInvalidNode(node)) {
      return false;
    }
    node = node.parentNode;
  }
  return true;
};

makeFunctionFromReplacementObject = function(rplc, strictCaps) {
  return function() {
    var el, i, ind, len, text;
    text = rplc.text;
    for (ind = i = 0, len = arguments.length; i < len; ind = ++i) {
      el = arguments[ind];
      text = text.replace(new RegExp("((\\$\\$)*)(\\$" + ind + ")", "g"), function(res, g1) {
        return "" + g1 + el;
      });
    }
    if (!strictCaps) {
      return text;
    } else if (arguments[0] === arguments[0].toUpperCase()) {
      return text.toUpperCase();
    } else if (arguments[0][0] === arguments[0][0].toUpperCase()) {
      return text.replace(/\b./g, function(match) {
        return match.toUpperCase();
      });
    } else {
      return text;
    }
  };
};

replaceAllFromJson = function(rplc, baseNode, nonRecursive) {
  var changeFns, fn, i, len, res, results;
  changeFns = rplc.map(function(el) {
    return function(txt) {
      var regPat;
      regPat = el.pattern;
      if (el.fullWord) {
        regPat = "\\b" + regPat + "\\b";
      }
      return txt.replace(new RegExp(regPat, "gi"), makeFunctionFromReplacementObject(el.replacement, el.strictCaps));
    };
  });
  if (nonRecursive) {
    if (isValidNode(baseNode)) {
      res = baseNode.data;
      for (i = 0, len = changeFns.length; i < len; i++) {
        fn = changeFns[i];
        res = fn(res);
      }
      if (baseNode.data !== res) {
        return baseNode.data = res;
      }
    }
  } else {
    results = html2Arr((baseNode || document).getElementsByTagName('*'));
    if (baseNode && baseNode !== document) {
      results = results.concat(baseNode);
    }
    results = results.filter(isValidNode);
    results = results.map(function(node) {
      return html2Arr(node.childNodes).filter(function(child) {
        return child.nodeType === 3;
      });
    });
    if (results.length > 0) {
      results = results.reduce(function(a, b) {
        return a.concat(b);
      });
      return results.forEach(function(node) {
        var j, len1;
        res = node.data;
        for (j = 0, len1 = changeFns.length; j < len1; j++) {
          fn = changeFns[j];
          res = fn(res);
        }
        if (node.data !== res) {
          return node.data = res;
        }
      });
    }
  }
};

watchNodesAndReplaceText = function(rplc) {
  var obsv, replaceAllFn;
  if (!rplc) {
    return;
  }
  replaceAllFn = function() {
    return replaceAllFromJson(rplc);
  };
  replaceAllFn();
  setTimeout(replaceAllFn, 500);
  setTimeout(replaceAllFn, 1000);
  obsv = new MutationObserver(function(records) {
    var i, len, rec, results1;
    results1 = [];
    for (i = 0, len = records.length; i < len; i++) {
      rec = records[i];
      switch (rec.type) {
        case 'characterData':
          results1.push(replaceAllFromJson(rplc, rec.target, true));
          break;
        case 'childList':
          if (rec.addedNodes.length > 0) {
            results1.push(replaceAllFromJson(rplc, rec.target, false));
          } else {
            results1.push(void 0);
          }
          break;
        default:
          results1.push(void 0);
      }
    }
    return results1;
  });
  return setTimeout((function() {
    replaceAllFn();
    return obsv.observe(document, {
      childList: true,
      subtree: true,
      characterData: true
    });
  }), 2000);
};

module.exports = {
  ReplaceAllFromJson: replaceAllFromJson,
  WatchNodesAndReplaceText: watchNodesAndReplaceText
};

},{}],2:[function(require,module,exports){
var Replace;

Replace = require('../common/replace-all');

self.port.emit('get-do-replacement');

self.port.on('get-do-replacement', function(doReplacement) {
  if (doReplacement) {
    self.port.emit('get-replacement-obj');
    return self.port.on('get-replacement-obj', Replace.WatchNodesAndReplaceText);
  }
});

},{"../common/replace-all":1}]},{},[2,1]);
