(window.webpackJsonp=window.webpackJsonp||[]).push([[4],{393:function(e,t,n){"use strict";var r,o,c=n(33);r=function(){var e,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=t.args,r=t.callback,o=t.logOrDebug,l=void 0===o?"debug":o;return(e=console)[l].apply(e,Object(c.a)(n)),"function"==typeof r&&r(),n[n.length-1]},o=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t})},o.breakpoint=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t,callback:function(){}})},o.always=function(){for(var e=arguments.length,t=new Array(e),n=0;n<e;n++)t[n]=arguments[n];return r({args:t,logOrDebug:"log"})},t.a=o},396:function(e,t,n){"use strict";var r=n(0),o=n(40),c=(n(1),n(51),n(15),n(3),n(5),n(4),n(2),n(6),n(7),n(408));function l(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function f(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?l(Object(source),!0).forEach((function(t){Object(r.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):l(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a=function(){var e,t,n,l,d,h=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},m=h.prefix,y=h.keys,v=h.format,O=void 0===v?"json":v;return"yaml"===O?(l=c.a.load,e=c.a.dump):(l=JSON.parse,e=JSON.stringify),n=!1,d=null,t=function(e){return m?"".concat(m,".").concat(e):e},{data:function(){return{localLoaded:new Promise((function(e){return d=e}))}},mounted:function(){var e=this;return y.forEach((function(n){var r,c,d,h,m;return m=localStorage.getItem(t(n)),r=e[n],console.log({key:n,localValue:m,defaultValue:r}),h="object"===Object(o.a)(r)&&null!==r,c=Array.isArray(r),d="number"==typeof r,m=h?l(m||null):d?parseFloat(m||null):"boolean"==typeof r?"boolean"==typeof m?m:"true"===m:m||null,e[n]=h&&!c?f(f({},r),m):m||r})),this.$nextTick((function(){return n=!0,d()}))},watch:f({},y.reduce((function(c,l){return Object.assign(c,Object(r.a)({},l,{deep:!0,handler:function(r){var c;if(n)return c=t(l),console.log("Syncing ".concat(l," to local storage key ").concat(c)),localStorage.setItem(c,"object"===Object(o.a)(r)?e(r):r)}}))}),{}))}}},400:function(e,t,n){var content=n(412);content.__esModule&&(content=content.default),"string"==typeof content&&(content=[[e.i,content,""]]),content.locals&&(e.exports=content.locals);(0,n(109).default)("55802022",content,!0,{sourceMap:!1})},405:function(e,t,n){"use strict";(function(e){n(5),n(4),n(2),n(1),n(6),n(3),n(7);var r=n(0),o=n(86),c=n.n(o);function l(object,e){var t=Object.keys(object);if(Object.getOwnPropertySymbols){var n=Object.getOwnPropertySymbols(object);e&&(n=n.filter((function(e){return Object.getOwnPropertyDescriptor(object,e).enumerable}))),t.push.apply(t,n)}return t}function f(e){for(var i=1;i<arguments.length;i++){var source=null!=arguments[i]?arguments[i]:{};i%2?l(Object(source),!0).forEach((function(t){Object(r.a)(e,t,source[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(source)):l(Object(source)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(source,t))}))}return e}t.a=function(){var t,n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},r=n.polygonAPIurl,o=void 0===r?"http://localhost:3700/api/polygon/":r,l=n.templatesDatabaseId,d=void 0===l?"485b3bd6b4524c1dbd9ef2acc5bccfbf":l,h=n.upvotesDatabaseId,m=void 0===h?"ecdca719f95b4eeab4c86118e44d162c":h,y=n.openAIkey,v=void 0===y?e.env.OPENAI_KEY:y,O=n.defaultParameters,j=void 0===O?{}:O;return t=c.a.create({baseURL:o}),{run:function(e){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},r=arguments.length>2&&void 0!==arguments[2]?arguments[2]:{};return console.log("Running",e,{variables:n,parameters:r}),t.post("/run",{databaseId:d,slug:e,openAIkey:v,variables:n,parameters:f(f({},j),r)}).then((function(e){return e.data}))},upvote:function(e){return console.log("Upvoting",e),t.post("/upvote",{databaseId:m,generationId:e}).then((function(e){return e.data}))}}}}).call(this,n(133))},410:function(e,t,n){"use strict";var r=n(11),o=n(135);r({target:"String",proto:!0,forced:n(136)("blink")},{blink:function(){return o(this,"blink","","")}})},411:function(e,t,n){"use strict";n(400)},412:function(e,t,n){var r=n(108)(!1);r.push([e.i,'#eyes[data-v-2517f130]{font-size:32px;font-family:monospace;white-space:pre}#monologue[data-v-2517f130]{font-size:20px;font-family:"Playfair Display","Georgia","Times New Roman","Times",serif}',""]),e.exports=r},423:function(e,t,n){"use strict";n.r(t);var r,o=n(33),c=n(35),l=n(34),f=(n(84),n(247),n(41),n(410),n(16),n(10),n(30),n(22),n(38),n(19),n(15),n(18),n(405)),d=n(393),h=n(396),m={mixins:[Object(h.a)({keys:["darkmodeEverUsed"],prefix:"mindy"})],props:{polygon:{type:f.a,required:!0},context:{default:"stuff"},usdSpent:{type:Number,required:!0}},data:function(){return{lines:[],blinkTimeout:null,getLineTimeout:null,darkmodeEverUsed:!1}},mounted:function(){return setTimeout(this.getLine,2e3*Math.random()+1e3),setTimeout(this.blink,2e3*Math.random()+1e3)},computed:{topics:function(){return this.context.split("\n").map((function(line){return line.trim().replace(/^[-*+]\s*/,"").toLowerCase()}))}},methods:{randomTopic:function(){var e;return Object(d.a)("Using topic",this.topics.length>1?(e=this.topics.slice(1),"".concat(this.topics[0]," and ").concat(e[Math.floor(Math.random()*e.length)])):this.topics[0])},getLine:(r=Object(l.a)(regeneratorRuntime.mark((function e(){var t,n,line,r,l,f,text,d,h;return regeneratorRuntime.wrap((function(e){for(;;)switch(e.prev=e.next){case 0:if(null!=(l=this.$refs)?l.container:void 0){e.next=2;break}return e.abrupt("return");case 2:return n=!!this.lines.length,f=n?"darkmode-continued":"darkmode",this.darkmodeEverUsed&&(f+="-repeated"),r=this.lines.join("”\nThen: “"),e.next=8,this.polygon.run(f,{topic:this.randomTopic(),previousLines:r},{max_tokens:50,temperature:.7,n:1,stop:["”",'"']});case 8:return d=e.sent,h=Object(c.a)(d.choices,1),text=h[0].text,t=d.approximateCost,this.$emit("update:usdSpent",this.usdSpent+t),this.darkmodeEverUsed=!0,(line=text.replace(/[”"\n].*/,"").trim())&&(this.lines=[].concat(Object(o.a)(this.lines),[line])),e.abrupt("return",this.getLineTimeout=setTimeout(this.getLine,2e3+4e3*Math.random()));case 17:case"end":return e.stop()}}),e,this)}))),function(){return r.apply(this,arguments)}),blink:function(){var e;if(null!=(e=this.$refs)?e.container:void 0)return document.getElementById("eyes").innerText=["( 👁️ )  ( 👁️ )","(    )   (    )","(  👁️)  (  👁️)","(👁️  )  (👁️  )"][Math.floor(4*Math.random())],this.blinkTimeout=setTimeout(this.blink,1e3*Math.random()+1e3)}},beforeDestroy:function(){return clearTimeout(this.blinkTimeout),clearTimeout(this.getLineTimeout)}},y=m,v=(n(411),n(68)),component=Object(v.a)(y,(function(){var e=this,t=e.$createElement,n=e._self._c||t;return n("b-container",{ref:"container",staticClass:"justify-content-center align-items-center text-center d-flex flex-column",staticStyle:{height:"100vh","background-color":"black",color:"white"},attrs:{fluid:""},on:{dblclick:function(t){return e.$emit("wheres-the-fucking-light-switch")}}},[n("b-row",[n("b-col",[n("p",{attrs:{id:"eyes"}},[e._v("( 👁️ )  ( 👁️ )")]),n("div",{staticClass:"mt-5"},e._l(e.lines,(function(line,t){return n("p",{key:t,attrs:{id:"monologue"},domProps:{textContent:e._s(line)}})})),0)])],1)],1)}),[],!1,null,"2517f130",null);t.default=component.exports}}]);