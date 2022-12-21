(window.webpackJsonp=window.webpackJsonp||[]).push([[7],{393:function(t,e,n){"use strict";var r,o,c,l=n(33);n(1);o=!1,r=function(){var t,e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=e.args,r=e.callback,c=e.method,f=void 0===c?"debug":c;o||((t=console)[f].apply(t,Object(l.a)(n)),"function"==typeof r&&r());return n[n.length-1]},c=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return r({args:e})},c.breakpoint=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return r({args:e,callback:function(){}})},["log","warn","debug","error"].forEach((function(t){return c[t]=function(){for(var e=arguments.length,n=new Array(e),o=0;o<e;o++)n[o]=arguments[o];return r({args:n,method:t})}})),c.disable=function(){return o=!0},e.a=c},405:function(t,e,n){"use strict";var r=n(0),o=n(35),c=n(40),l=(n(1),n(51),n(18),n(2),n(16),n(3),n(15),n(24),n(5),n(4),n(6),n(7),n(438)),f=n(393),d=n(394),h=n.n(d);function m(object,t){var e=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(object,t).enumerable}))),e.push.apply(e,n)}return e}function y(t){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?m(Object(source),!0).forEach((function(e){Object(r.a)(t,e,source[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(source)):m(Object(source)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(source,e))}))}return t}e.a=function(){var t,e,n,d,m,v,O,j=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},k=j.prefix,w=j.keys,x=j.format,P=void 0===x?"json":x;return Object(f.a)("Exporting syncLocal mixin with arguments: ".concat(JSON.stringify(arguments[0]))),"yaml"===P?(m=l.a.load,n=l.a.dump):(m=JSON.parse,n=JSON.stringify),O=null,t=function(t,e){return"object"===Object(c.a)(e)&&null!==e?m(t||null):"number"==typeof e?parseFloat(t||null):"boolean"==typeof e?"boolean"==typeof t?t:"true"===t:t||null},v=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return e.filter(h.a.identity).join(".")},Object(f.a)("Using data paths:",e=w.reduce((function(t,e){var n;if(h.a.isArray(e)){var c=e,l=Object(o.a)(c,2);e=l[0],n=l[1].dataPath}return Object.assign(t,Object(r.a)({},e,v(n,e)))}),{})),Object(f.a)("Converted keys back to plain strings:",w=w.map((function(t){return h.a.isArray(t)?t[0]:t}))),Object(f.a)("Using local keys:",d=w.reduce((function(t,e){return Object.assign(t,Object(r.a)({},e,v(k,e)))}),{})),{data:function(){return{syncLocal:{promise:new Promise((function(t){return O=t})),values:null,loaded:!1,ignoreWatchers:[]}}},mounted:function(){var n=this;return w.forEach((function(r){var o,c,l;if(Object(f.a)("Syncing key ".concat(r," from local storage for component ").concat(n.$options.name)),Object(f.a)("Local value:",l=window.localStorage.getItem(d[r])),o=e[r],void 0===(c=h.a.get(n,o)))throw new Error("Default value for key `".concat(r,"` does not exist at `").concat(o,"`"));return console.log({key:r,localValue:l,defaultValue:c}),l=t(l,c),h.a.set(n,o,Object(f.a)("Setting ".concat(r," at ").concat(o," to:"),h.a.isObject(c)&&!h.a.isArray(c)?y(y({},c),l):l||c))})),this.$nextTick((function(){return Object.assign(n.syncLocal,{values:h.a.mapValues(e,(function(t){return h.a.get(n,t)})),loaded:!0}),O(n.syncLocal.values)}))},watch:y({},w.reduce((function(t,e){return Object.assign(t,Object(r.a)({},e,{deep:!0,handler:function(t){var r;return this.syncLocal.loaded?(r=d[e],window.localStorage.setItem(r,"object"===Object(c.a)(t)?n(t):t),Object(f.a)("Saved ".concat(e," to local storage as ").concat(r)),this.syncLocal.ignoreWatchers=h.a.without(this.syncLocal.ignoreWatchers,e)):this.syncLocal.ignoreWatchers.push(e)}}))}),{}))}}},408:function(t,e,n){"use strict";(function(t){n(5),n(4),n(2),n(1),n(6),n(3),n(7);var r=n(0),o=n(85),c=n.n(o),l=n(393);function f(object,t){var e=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);t&&(n=n.filter((function(t){return Object.getOwnPropertyDescriptor(object,t).enumerable}))),e.push.apply(e,n)}return e}function d(t){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?f(Object(source),!0).forEach((function(e){Object(r.a)(t,e,source[e])})):Object.getOwnPropertyDescriptors?Object.defineProperties(t,Object.getOwnPropertyDescriptors(source)):f(Object(source)).forEach((function(e){Object.defineProperty(t,e,Object.getOwnPropertyDescriptor(source,e))}))}return t}e.a=function(){var e,n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},r=n.polygonAPIurl,o=void 0===r?"https://ideality.app/api/polygon/":r,f=n.templatesDatabaseId,h=void 0===f?"485b3bd6b4524c1dbd9ef2acc5bccfbf":f,m=n.upvotesDatabaseId,y=void 0===m?"ecdca719f95b4eeab4c86118e44d162c":m,v=n.openAIkey,O=void 0===v?t.env.OPENAI_KEY:v,j=n.defaultParameters,k=void 0===j?{}:j,w=n.spent,x=n.vm,P=n.vmKey;return e=c.a.create({baseURL:o}),console.log("Polygon client initialized",{polygonAPIurl:o,templatesDatabaseId:h,upvotesDatabaseId:y,openAIkey:O,defaultParameters:k}),{spent:w,run:function(t){var n=this,r=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},o=arguments.length>2&&void 0!==arguments[2]?arguments[2]:{};return console.log("Running",t,{variables:r,parameters:o}),e.post("/run",{databaseId:h,slug:t,openAIkey:O,variables:r,parameters:d(d({},k),o)}).then((function(t){var data=t.data;return Object(l.a)("USD spent",n.spent+=data.approximateCost),x&&(x[P]=n.spent),data}))},upvote:function(t){return console.log("Upvoting",t),e.post("/upvote",{databaseId:y,generationId:t}).then((function(t){return t.data}))}}}}).call(this,n(134))},430:function(t,e,n){var content=n(491);content.__esModule&&(content=content.default),"string"==typeof content&&(content=[[t.i,content,""]]),content.locals&&(t.exports=content.locals);(0,n(109).default)("7b7cf660",content,!0,{sourceMap:!1})},489:function(t,e,n){"use strict";var r=n(12),o=n(135);r({target:"String",proto:!0,forced:n(136)("blink")},{blink:function(){return o(this,"blink","","")}})},490:function(t,e,n){"use strict";n(430)},491:function(t,e,n){var r=n(108)(!1);r.push([t.i,'#eyes[data-v-d9afa138]{font-size:32px;font-family:monospace;white-space:pre}#monologue[data-v-d9afa138]{font-size:20px;font-family:"Playfair Display","Georgia","Times New Roman","Times",serif}',""]),t.exports=r},530:function(t,e,n){"use strict";n.r(e);var r,o=n(33),c=n(35),l=n(34),f=(n(84),n(41),n(489),n(16),n(11),n(30),n(22),n(37),n(19),n(15),n(18),n(1),n(408)),d=n(393),h=n(405),m={mixins:[Object(h.a)({keys:["darkmodeEverUsed"],prefix:"mindy"})],props:{polygon:{type:f.a,required:!0},context:{default:"stuff"}},data:function(){return{lines:[],blinkTimeout:null,getLineTimeout:null,darkmodeEverUsed:!1}},mounted:function(){return setTimeout(this.getLine,2e3*Math.random()+1e3),setTimeout(this.blink,2e3*Math.random()+1e3)},computed:{topics:function(){return this.context.split("\n").map((function(line){return line.trim().replace(/^[-*+]\s*/,"").toLowerCase()}))}},methods:{randomTopic:function(){var t;return Object(d.a)("Using topic",this.topics.length>1?(t=this.topics.slice(1),"".concat(this.topics[0]," and ").concat(t[Math.floor(Math.random()*t.length)])):this.topics[0])},getLine:(r=Object(l.a)(regeneratorRuntime.mark((function t(){var e,line,n,r,l,text,f,d;return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:if(null!=(r=this.$refs)?r.container:void 0){t.next=2;break}return t.abrupt("return");case 2:return e=!!this.lines.length,l=e?"darkmode-continued":"darkmode",this.darkmodeEverUsed&&(l+="-repeated"),n=this.lines.join("”\nThen: “"),t.next=8,this.polygon.run(l,{topic:this.randomTopic(),previousLines:n},{max_tokens:50,temperature:.7,n:1,stop:["”",'"']});case 8:return f=t.sent,d=Object(c.a)(f.choices,1),text=d[0].text,f.approximateCost,this.darkmodeEverUsed=!0,(line=text.replace(/[”"\n].*/,"").trim())&&(this.lines=[].concat(Object(o.a)(this.lines),[line])),t.abrupt("return",this.getLineTimeout=setTimeout(this.getLine,2e3+4e3*Math.random()));case 16:case"end":return t.stop()}}),t,this)}))),function(){return r.apply(this,arguments)}),blink:function(){var t;if(null!=(t=this.$refs)?t.container:void 0)return document.getElementById("eyes").innerText=["( 👁️ )  ( 👁️ )","(    )   (    )","(  👁️)  (  👁️)","(👁️  )  (👁️  )"][Math.floor(4*Math.random())],this.blinkTimeout=setTimeout(this.blink,1e3*Math.random()+1e3)},turnOnTheLights:function(){var t,e;return e=null,t=new Promise((function(t){return e=t})),this.$emit("wheres-the-fucking-light-switch",t),this.lines.length?this.polygon.run("darkmode-ended",{topic:"stuff",previousLines:this.lines.join("”\nThen: “")},{max_tokens:50,temperature:.7,n:1,stop:["”",'"']}).then((function(t){var text=Object(c.a)(t.choices,1)[0].text;return e(text)})):e()}},beforeDestroy:function(){return clearTimeout(this.blinkTimeout),clearTimeout(this.getLineTimeout)}},y=m,v=(n(490),n(68)),component=Object(v.a)(y,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-container",{ref:"container",staticClass:"justify-content-center align-items-center text-center d-flex flex-column",staticStyle:{height:"100vh","background-color":"black",color:"white"},attrs:{fluid:""},on:{dblclick:t.turnOnTheLights}},[n("b-row",[n("b-col",[n("p",{attrs:{id:"eyes"}},[t._v("( 👁️ )  ( 👁️ )")]),n("div",{staticClass:"mt-5"},t._l(t.lines,(function(line,e){return n("p",{key:e,attrs:{id:"monologue"},domProps:{textContent:t._s(line)}})})),0)])],1)],1)}),[],!1,null,"d9afa138",null);e.default=component.exports}}]);