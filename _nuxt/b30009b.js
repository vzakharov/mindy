(window.webpackJsonp=window.webpackJsonp||[]).push([[22],{393:function(e,t,n){"use strict";var r,o,c,l=n(33);n(1);o=!1,r=function(){var e,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=t.args,r=t.callback,c=t.method,f=void 0===c?"debug":c;o||((e=console)[f].apply(e,Object(l.a)(n)),"function"==typeof r&&r());return n[n.length-1]},c=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t})},c.breakpoint=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t,callback:function(){}})},["log","warn","debug","error"].forEach((function(e){return c[e]=function(){for(var t=arguments.length,n=new Array(t),o=0;o<t;o++)n[o]=arguments[o];return r({args:n,method:e})}})),c.disable=function(){return o=!0},t.a=c},398:function(e,t,n){"use strict";var r,o=n(0),c=n(34);n(84),n(1),n(15),n(5),n(4),n(2),n(6),n(3),n(7);function l(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function f(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?l(Object(source),!0).forEach((function(t){Object(o.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):l(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a={data:function(){return{whilst:{}}},methods:{actionPromise:function(e){var t;return null!=(t=this.whilst[e])?t:Promise.resolve()},try:(r=Object(c.a)(regeneratorRuntime.mark((function e(t,n){var r,o,c,l,track,d,y,h,v,k,O,m=arguments;return regeneratorRuntime.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:return r=m.length>2&&void 0!==m[2]?m[2]:{},o=r.errorMessage,c=r.except,l=r.track,track=void 0===l||l,d=r.mixpanelProps,track&&(h=this.mixpanel),this[t]=!0,k=null,v=null,this.whilst[t]=new Promise((function(e,t){return k=e,v=t})),e.prev=6,console.log("Started ".concat(t)),null!=h&&h.track("".concat(t," started"),d),e.t0=k,e.next=12,n.call(this);case 12:return e.t1=O=e.sent,(0,e.t0)(e.t1),null!=h&&h.track("".concat(t," succeeded"),d),e.abrupt("return",O);case 18:return e.prev=18,e.t2=e.catch(6),y=e.t2,console.error("Error while ".concat(t,": ").concat(y)),null!=h&&h.track("".concat(t," failed"),f({error:y.message},d)),"function"==typeof o&&(o=o(y)),this.alert(o),"function"==typeof c&&c(y),e.abrupt("return",v(y));case 27:return e.prev=27,this[t]=!1,console.log("Finished ".concat(t)),e.finish(27);case 31:case"end":return e.stop()}}),e,this,[[6,18,27,31]])}))),function(e,t){return r.apply(this,arguments)}),alert:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"Something went wrong.";return this.$bvToast.toast("See console for error details.",{title:e,variant:"danger",solid:!0,autoHideDelay:5e3})}}}},400:function(e,t,n){"use strict";var r=n(425),o=n.n(r);t.a={data:function(){return o.a.init("f9ed5012981005142ed33251c919eb41",{debug:!0}),{mixpanel:o.a}}}},405:function(e,t,n){"use strict";var r=n(0),o=n(35),c=n(40),l=(n(1),n(51),n(18),n(2),n(16),n(3),n(15),n(24),n(5),n(4),n(6),n(7),n(438)),f=n(393),d=n(394),y=n.n(d);function h(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function v(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?h(Object(source),!0).forEach((function(t){Object(r.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):h(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a=function(){var e,t,n,d,h,k,O,m=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},w=m.prefix,j=m.keys,A=m.format,I=void 0===A?"json":A;return Object(f.a)("Exporting syncLocal mixin with arguments: ".concat(JSON.stringify(arguments[0]))),"yaml"===I?(h=l.a.load,n=l.a.dump):(h=JSON.parse,n=JSON.stringify),O=null,e=function(e,t){return"object"===Object(c.a)(t)&&null!==t?h(e||null):"number"==typeof t?parseFloat(e||null):"boolean"==typeof t?"boolean"==typeof e?e:"true"===e:e||null},k=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return t.filter(y.a.identity).join(".")},Object(f.a)("Using data paths:",t=j.reduce((function(e,t){var n;if(y.a.isArray(t)){var c=t,l=Object(o.a)(c,2);t=l[0],n=l[1].dataPath}return Object.assign(e,Object(r.a)({},t,k(n,t)))}),{})),Object(f.a)("Converted keys back to plain strings:",j=j.map((function(e){return y.a.isArray(e)?e[0]:e}))),Object(f.a)("Using local keys:",d=j.reduce((function(e,t){return Object.assign(e,Object(r.a)({},t,k(w,t)))}),{})),{data:function(){return{syncLocal:{promise:new Promise((function(e){return O=e})),values:null,loaded:!1,ignoreWatchers:[]}}},mounted:function(){var n=this;return j.forEach((function(r){var o,c,l;if(Object(f.a)("Syncing key ".concat(r," from local storage for component ").concat(n.$options.name)),Object(f.a)("Local value:",l=window.localStorage.getItem(d[r])),o=t[r],void 0===(c=y.a.get(n,o)))throw new Error("Default value for key `".concat(r,"` does not exist at `").concat(o,"`"));return console.log({key:r,localValue:l,defaultValue:c}),l=e(l,c),y.a.set(n,o,Object(f.a)("Setting ".concat(r," at ").concat(o," to:"),y.a.isObject(c)&&!y.a.isArray(c)?v(v({},c),l):l||c))})),this.$nextTick((function(){return Object.assign(n.syncLocal,{values:y.a.mapValues(t,(function(e){return y.a.get(n,e)})),loaded:!0}),O(n.syncLocal.values)}))},watch:v({},j.reduce((function(e,t){return Object.assign(e,Object(r.a)({},t,{deep:!0,handler:function(e){var r;return this.syncLocal.loaded?(r=d[t],window.localStorage.setItem(r,"object"===Object(c.a)(e)?n(e):e),Object(f.a)("Saved ".concat(t," to local storage as ").concat(r)),this.syncLocal.ignoreWatchers=y.a.without(this.syncLocal.ignoreWatchers,t)):this.syncLocal.ignoreWatchers.push(t)}}))}),{}))}}},531:function(e,t,n){"use strict";n.r(t);var r=n(34),o=(n(84),n(85)),c=n.n(o),l=n(398),f=n(400),d=n(405),y={mixins:[l.a,f.a,Object(d.a)({keys:["acknowledged"],prefix:"mindy"})],props:["value"],data:function(){return console.log("OpenAIKeyModal value: ".concat(this.value)),{openAIkey:this.value,checkingKey:!1,keyValid:!!this.value,acknowledged:!1}},computed:{canClose:function(){return this.openAIkey&&this.keyValid&&this.acknowledged}},methods:{show:function(){return this.$refs.openAIKeyModal.show()},hide:function(){return this.$refs.openAIKeyModal.hide()},checkKey:function(){var e=this;return this.try("checkingKey",Object(r.a)(regeneratorRuntime.mark((function t(){return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return console.log("Checking key ".concat(e.openAIkey)),t.next=3,c.a.post("https://api.openai.com/v1/engines/text-ada-001/completions",{prompt:"Hello",max_tokens:1},{headers:{Authorization:"Bearer ".concat(e.openAIkey)}});case 3:return e.$bvToast.toast("Yay, the key is valid! Enjoy the app!",{title:"Success",variant:"success",autoHideDelay:3e3}),e.keyValid=!0,e.$emit("input",e.openAIkey),t.abrupt("return",e.mixpanel.track("OpenAI key validated"));case 7:case"end":return t.stop()}}),t)}))),{errorMessage:function(e){var t;return 401===(null!=e&&null!=(t=e.response)?t.status:void 0)&&"Invalid API key"},except:function(){return e.mixpanel.track("Error checking OpenAI key")}})}}},h=n(68),component=Object(h.a)(y,(function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("b-modal",{ref:"openAIKeyModal",attrs:{title:"Enter your OpenAI API key","hide-footer":!e.canClose,"no-close-on-backdrop":!e.canClose,"no-close-on-esc":!e.canClose,"hide-header-close":!e.canClose,"ok-only":""}},[n("h4",[e._v("Why?")]),n("p",[e._v("This app uses the OpenAI API to generate texts.\nWe "),n("a",{attrs:{href:"https://github.com/vzakharov/ideality-nuxt/blob/master/api/polygon/index.coffee",target:"_blank"}},[e._v("do not store")]),e._v("\nyour API key anywhere on our servers.")]),n("p",[e._v("You can get your OpenAI key "),n("a",{attrs:{href:"https://beta.openai.com/account/api-keys",target:"_blank"}},[e._v("here")]),e._v(".")]),n("b-form",{on:{submit:function(t){return t.preventDefault(),e.checkKey()}}},[n("b-form-group",{attrs:{label:"OpenAI API key","label-for":"openAIkey"}},[n("b-form-input",{attrs:{id:"openAIkey",type:"text",placeholder:"sk-...",disabled:e.checkingKey},model:{value:e.openAIkey,callback:function(t){e.openAIkey=t},expression:"openAIkey"}})],1),n("b-button",{attrs:{type:"submit",variant:e.keyValid?"outline-secondary":"primary",disabled:!e.openAIkey||e.checkingKey}},[n("b-spinner",{directives:[{name:"show",rawName:"v-show",value:e.checkingKey,expression:"checkingKey"}],attrs:{small:"",type:"grow"}}),e._v(e._s(e.checkingKey?"Checking...":"Check and save"))],1)],1),n("b-checkbox",{staticClass:"mt-4",staticStyle:{"font-size":"1.2em"},model:{value:e.acknowledged,callback:function(t){e.acknowledged=t},expression:"acknowledged"}},[e._v("I understand that I will be spending my own OpenAI tokens (credits) to generate texts.")])],1)}),[],!1,null,null,null);t.default=component.exports}}]);