(window.webpackJsonp=window.webpackJsonp||[]).push([[9],{392:function(e,t,n){"use strict";var r,o,c=n(33);r=function(){var e,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=t.args,r=t.callback,o=t.logOrDebug,l=void 0===o?"debug":o;return(e=console)[l].apply(e,Object(c.a)(n)),"function"==typeof r&&r(),n[n.length-1]},o=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t})},o.breakpoint=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t,callback:function(){}})},o.always=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t,logOrDebug:"log"})},t.a=o},396:function(e,t,n){"use strict";var r=n(0),o=n(40),c=(n(1),n(51),n(15),n(3),n(5),n(4),n(2),n(6),n(7),n(409)),l=n(392),f=n(400),d=n.n(f);function h(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function y(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?h(Object(source),!0).forEach((function(t){Object(r.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):h(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a=function(){var e,t,n,f,h,v,k=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},m=k.prefix,O=k.keys,w=k.format,j=void 0===w?"json":w;return"yaml"===j?(h=c.a.load,t=c.a.dump):(h=JSON.parse,t=JSON.stringify),f=!1,v=null,n=function(e){return m?"".concat(m,".").concat(e):e},e=function(e,t){return"object"===Object(o.a)(t)&&null!==t?h(e||null):"number"==typeof t?parseFloat(e||null):"boolean"==typeof t?"boolean"==typeof e?e:"true"===e:e||null},{data:function(){return{localLoaded:new Promise((function(e){return v=e})),watchersToIgnore:[]}},mounted:function(){var t=this;return O.forEach((function(r){var o,c;return c=localStorage.getItem(n(r)),o=t[r],console.log({key:r,localValue:c,defaultValue:o}),c=e(c,o),t[r]=d.a.isObject(o)&&!d.a.isArray(o)?y(y({},o),c):c||o,t.$nextTick((function(){return f=!0,v()}))}))},watch:y({},O.reduce((function(e,c){return Object.assign(e,Object(r.a)({},c,{deep:!0,handler:function(e){var r;return f?(r=n(c),localStorage.setItem(r,"object"===Object(o.a)(e)?t(e):e),Object(l.a)("Saved ".concat(c," to local storage as ").concat(r)),this.watchersToIgnore=d.a.without(this.watchersToIgnore,c)):this.watchersToIgnore.push(c)}}))}),{}))}}},397:function(e,t,n){"use strict";var r=n(410),o=n.n(r);t.a={data:function(){return o.a.init("f9ed5012981005142ed33251c919eb41",{debug:!0}),{mixpanel:o.a}}}},405:function(e,t,n){"use strict";var r,o=n(0),c=n(34);n(84),n(1),n(15),n(5),n(4),n(2),n(6),n(3),n(7);function l(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function f(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?l(Object(source),!0).forEach((function(t){Object(o.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):l(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a={data:function(){return{actionPromises:{}}},methods:{actionPromise:function(e){var t;return null!=(t=this.actionPromises[e])?t:Promise.resolve()},try:(r=Object(c.a)(regeneratorRuntime.mark((function e(t,n){var r,o,c,l,track,d,h,y,v,k,m=arguments;return regeneratorRuntime.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:return r=m.length>2&&void 0!==m[2]?m[2]:{},o=r.errorMessage,c=r.except,l=r.track,track=void 0===l||l,d=r.mixpanelProps,track&&(y=this.mixpanel),this[t]=!0,k=null,v=null,this.actionPromises[t]=new Promise((function(e,t){return k=e,v=t})),e.prev=6,console.log("Started ".concat(t)),null!=y&&y.track("".concat(t," started"),d),e.t0=k,e.next=12,n();case 12:return e.t1=e.sent,(0,e.t0)(e.t1),e.abrupt("return",null!=y?y.track("".concat(t," succeeded"),d):void 0);case 17:return e.prev=17,e.t2=e.catch(6),h=e.t2,console.error("Error while ".concat(t,": ").concat(h)),null!=y&&y.track("".concat(t," failed"),f({error:h.message},d)),"function"==typeof o&&(o=o(h)),this.alert(o),"function"==typeof c&&c(h),e.abrupt("return",v(h));case 26:return e.prev=26,this[t]=!1,console.log("Finished ".concat(t)),e.finish(26);case 30:case"end":return e.stop()}}),e,this,[[6,17,26,30]])}))),function(e,t){return r.apply(this,arguments)}),alert:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"Something went wrong.";return this.$bvToast.toast("See console for error details.",{title:e,variant:"danger",solid:!0,autoHideDelay:5e3})}}}},424:function(e,t,n){"use strict";n.r(t);var r=n(34),o=(n(84),n(86)),c=n.n(o),l=n(405),f=n(397),d=n(396),h={mixins:[l.a,f.a,Object(d.a)({keys:["acknowledged"],prefix:"mindy"})],props:["value"],data:function(){return console.log("OpenAIKeyModal value: ".concat(this.value)),{openAIkey:this.value,checkingKey:!1,keyValid:!!this.value,acknowledged:!1}},computed:{canClose:function(){return this.openAIkey&&this.keyValid&&this.acknowledged}},methods:{show:function(){return this.$refs.openAIKeyModal.show()},hide:function(){return this.$refs.openAIKeyModal.hide()},checkKey:function(){var e=this;return this.try("checkingKey",Object(r.a)(regeneratorRuntime.mark((function t(){return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:return console.log("Checking key ".concat(e.openAIkey)),t.next=3,c.a.post("https://api.openai.com/v1/engines/text-ada-001/completions",{prompt:"Hello",max_tokens:1},{headers:{Authorization:"Bearer ".concat(e.openAIkey)}});case 3:return e.$bvToast.toast("Yay, the key is valid! Enjoy the app!",{title:"Success",variant:"success",autoHideDelay:3e3}),e.keyValid=!0,e.$emit("input",e.openAIkey),t.abrupt("return",e.mixpanel.track("OpenAI key validated"));case 7:case"end":return t.stop()}}),t)}))),{errorMessage:function(e){var t;return 401===(null!=e&&null!=(t=e.response)?t.status:void 0)&&"Invalid API key"},except:function(){return e.mixpanel.track("Error checking OpenAI key")}})}}},y=n(68),component=Object(y.a)(h,(function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("b-modal",{ref:"openAIKeyModal",attrs:{title:"Enter your OpenAI API key","hide-footer":!e.canClose,"no-close-on-backdrop":!e.canClose,"no-close-on-esc":!e.canClose,"hide-header-close":!e.canClose,"ok-only":""}},[n("h4",[e._v("Why?")]),n("p",[e._v("This app uses the OpenAI API to generate texts.\nWe "),n("a",{attrs:{href:"https://github.com/vzakharov/ideality-nuxt/blob/master/api/polygon/index.coffee",target:"_blank"}},[e._v("do not store")]),e._v("\nyour API key anywhere on our servers.")]),n("p",[e._v("You can get your OpenAI key "),n("a",{attrs:{href:"https://beta.openai.com/account/api-keys",target:"_blank"}},[e._v("here")]),e._v(".")]),n("b-form",{on:{submit:function(t){return t.preventDefault(),e.checkKey()}}},[n("b-form-group",{attrs:{label:"OpenAI API key","label-for":"openAIkey"}},[n("b-form-input",{attrs:{id:"openAIkey",type:"text",placeholder:"sk-...",disabled:e.checkingKey},model:{value:e.openAIkey,callback:function(t){e.openAIkey=t},expression:"openAIkey"}})],1),n("b-button",{attrs:{type:"submit",variant:e.keyValid?"outline-secondary":"primary",disabled:!e.openAIkey||e.checkingKey}},[n("b-spinner",{directives:[{name:"show",rawName:"v-show",value:e.checkingKey,expression:"checkingKey"}],attrs:{small:"",type:"grow"}}),e._v(e._s(e.checkingKey?"Checking...":"Check and save"))],1)],1),n("b-checkbox",{staticClass:"mt-4",staticStyle:{"font-size":"1.2rem"},model:{value:e.acknowledged,callback:function(t){e.acknowledged=t},expression:"acknowledged"}},[e._v("I understand that I will be spending my own OpenAI tokens (credits) to generate texts.")])],1)}),[],!1,null,null,null);t.default=component.exports}}]);