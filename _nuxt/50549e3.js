(window.webpackJsonp=window.webpackJsonp||[]).push([[7,5,6],{392:function(t,e,n){"use strict";var r,o,c=n(33);r=function(){var t,e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=e.args,r=e.callback,o=e.logOrDebug,l=void 0===o?"debug":o;return(t=console)[l].apply(t,Object(c.a)(n)),"function"==typeof r&&r(),n[n.length-1]},o=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return r({args:e})},o.breakpoint=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return r({args:e,callback:function(){}})},o.always=function(){for(var t=arguments.length,e=new Array(t),n=0;n<t;n++)e[n]=arguments[n];return r({args:e,logOrDebug:"log"})},e.a=o},393:function(t,e,n){"use strict";var r,o=n(0);r=function(t){return t},e.a=function(t){var e,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},c=n.deep,l=n.save,d=void 0===l?r:l,m=n.load,f=void 0===m?r:m;return{data:function(){return Object(o.a)({},t,null)},watch:(e={},Object(o.a)(e,t,{deep:c,handler:function(t){return this.$emit("input",d.call(this,t))}}),Object(o.a)(e,"value",{deep:c,immediate:!0,handler:function(e){return this[t]=f.call(this,e)}}),e)}}},397:function(t,e,n){"use strict";var r=n(410),o=n.n(r);e.a={data:function(){return o.a.init("f9ed5012981005142ed33251c919eb41",{debug:!0}),{mixpanel:o.a}}}},398:function(t,e,n){"use strict";n.r(e);var r,o=n(40),c=(n(247),n(15),n(19),n(1),n(37),n(4),n(62),n(10),n(30),n(22),n(393));r=function(t){return"number"===this.inputProps.type?Number(t):t};var l={mixins:[Object(c.a)("setting",{save:r,load:r})],props:{value:{required:!0},properties:{type:Object,default:function(){return{}}}},computed:{id:function(){return"edit-settings-input-".concat(this.$vnode.key,"-").concat(Math.random().toString(36).slice(2))},label:function(){return this.properties.label||this.$vnode.key},description:function(){var t;return t=this.properties.description,(null!=t?t[!0]:void 0)&&t[!1]?t[this.setting]:t},inputTagAndProps:function(){var t,e,n=this;if(e={multiline:function(){var t;return{tag:"b-textarea",props:{rows:Math.max(10,Math.min(20,null!=(t=n.value)?t.split("\n").length:void 0)),style:n.properties.monospace?"font-family: monospace; tab-size: 2; -moz-tab-size: 2;":"",placeholder:n.properties.placeholder||"Enter text here"}}},text:{tag:"b-input",props:{type:"text",placeholder:this.properties.placeholder||"Enter text here"}},number:{tag:"b-input",props:{type:"number",placeholder:this.properties.placeholder||"Enter a number here"}},boolean:{tag:"b-checkbox",props:{switch:!0}}},this.properties.type)return("function"==typeof(t=e[this.properties.type])?t():void 0)||t;switch(Object(o.a)(this.value)){case"number":return e.number;case"boolean":return e.boolean;default:return e.text}},inputTag:function(){return this.inputTagAndProps.tag},inputProps:function(){return this.inputTagAndProps.props}},methods:{onTab:function(t){var e,n,r,o,c,l,d=this;if(this.properties.monospace){var m=this.$refs.input.$el;return o=m.selectionStart,r=m.selectionEnd,l=this.value.substring(0,o),n=this.value.substring(o,r),c=this.value.substring(r),e=l.lastIndexOf("\n")||0,n=l.substring(e+1,o)+n,l=l.substring(0,e+1),n=n.replace(/(\n|^)(\t?)/g,t.shiftKey?"$1":"$1$2\t"),this.setting=l+n+c,t.preventDefault(),this.$nextTick((function(){return d.$refs.input.$el.setSelectionRange(o+(t.shiftKey?-1:1),r+(t.shiftKey?-1:1))}))}}}},d=n(68),component=Object(d.a)(l,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-form-group",t._b({attrs:{"label-for":t.id}},"b-form-group",{label:t.label,description:t.description},!1),[n(t.inputTag,t._b({ref:"input",tag:"component",attrs:{id:t.id},on:{keydown:function(e){return!e.type.indexOf("key")&&t._k(e.keyCode,"tab",9,e.key,"Tab")?null:t.onTab.apply(null,arguments)}},model:{value:t.setting,callback:function(e){t.setting=e},expression:"setting"}},"component",t.inputProps,!1))],1)}),[],!1,null,null,null);e.default=component.exports},399:function(t,e,n){"use strict";var r=n(172).start,o=n(248);t.exports=o("trimStart")?function(){return r(this)}:"".trimStart},402:function(t,e,n){var content=n(415);content.__esModule&&(content=content.default),"string"==typeof content&&(content=[[t.i,content,""]]),content.locals&&(t.exports=content.locals);(0,n(109).default)("d344a20e",content,!0,{sourceMap:!1})},403:function(t,e,n){"use strict";n.r(e);var r=n(393),o={mixins:[Object(r.a)("settings",{deep:!0})],props:{title:{type:String,default:"Edit settings"},okTitle:{type:String,default:"Save"},cancelTitle:{type:String,default:"Cancel"},value:{type:Object,required:!0},properties:{type:Object,default:function(){return{}}}}},c=n(68),component=Object(c.a)(o,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-form",{staticStyle:{width:"100%"}},t._l(t.settings,(function(e,r){return n("EditSettingsInput",{key:r,attrs:{properties:t.properties[r]},model:{value:t.settings[r],callback:function(e){t.$set(t.settings,r,e)},expression:"settings[key]"}})})),1)}),[],!1,null,null,null);e.default=component.exports;installComponents(component,{EditSettingsInput:n(398).default})},404:function(t,e,n){n(407);var r=n(11),o=n(399);r({target:"String",proto:!0,name:"trimStart",forced:"".trimStart!==o},{trimStart:o})},407:function(t,e,n){var r=n(11),o=n(399);r({target:"String",proto:!0,name:"trimStart",forced:"".trimLeft!==o},{trimLeft:o})},414:function(t,e,n){"use strict";n(402)},415:function(t,e,n){var r=n(108)(!1);r.push([t.i,".code[data-v-0a55d814]{font-family:monospace;background-color:#1e1e1e;color:#d4d4d4;height:calc(100% - 2.5em)}",""]),t.exports=r},422:function(t,e,n){"use strict";n.r(e);n(171);var r,o,c=n(34),l=n(29),d=n(28),m=n(67),f=n(126),h=n(49),v=n(166),x=(n(84),n(404),n(10),n(22),n(1),n(3),n(18),n(16),n(63),n(50),n(30),n(392)),y={data:function(){var t;return t={state:!1},Object.assign(t,{promise:new Promise((function(e){return Object.assign(t,{resolve:e})}))}),{mounted:t}},mounted:function(){return this.mounted.resolve(),this.mounted.state=!0}},w=n(397);function k(t){var e=function(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Boolean.prototype.valueOf.call(Reflect.construct(Boolean,[],(function(){}))),!0}catch(t){return!1}}();return function(){var n,r=Object(h.a)(t);if(e){var o=Object(h.a)(this).constructor;n=Reflect.construct(r,arguments,o)}else n=r.apply(this,arguments);return Object(f.a)(this,n)}}r=function(t){Object(m.a)(n,t);var e=k(n);function n(){return Object(d.a)(this,n),e.apply(this,arguments)}return Object(l.a)(n)}(Object(v.a)(Error)),o=function(line){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:2;return(line.length-line.trimLeft().length)/t};var j,O={mixins:[y,w.a],props:["value","readonly"],data:function(){return{chartRendered:!1,editInPlainText:!1,wasInvalid:!1,contextChanged:!1}},computed:{context:{get:function(){return this.value},set:function(t){return this.$emit("input",t)}},isValid:function(){var t;try{return this.validate(this.context),this.wasInvalid&&(this.wasInvalid=!1,this.mixpanel.track("Context fixed")),!0}catch(e){return t=e,console.error(t),this.wasInvalid||(this.wasInvalid=!0,this.mixpanel.track("Invalid context")),!1}},mermaidString:function(){var t;try{this.validate(this.context)}catch(t){return t,""}return t="mindmap\n"+this.context.replace(/[~@\-~"()]/g,(function(t){return"#".concat(t.charCodeAt(0),";")})),console.log(t),t}},mounted:function(){var script;return console.log("MindyContext mounted"),document.getElementById("mermaid-init")?console.log("mermaid-init script already exists"):(console.log("creating mermaid-init script"),(script=document.createElement("script")).id="mermaid-init",script.type="module",window.mermaidLoaded={state:!1,resolve:null},window.mermaidLoaded.promise=new Promise((function(t){return Object.assign(window.mermaidLoaded,{resolve:t})})),script.innerHTML="let resolve = null\nimport mermaid from 'https://unpkg.com/mermaid@9/dist/mermaid.esm.mjs';\nconsole.log({mermaid})\nimport mindmap from 'https://unpkg.com/@mermaid-js/mermaid-mindmap@9/dist/mermaid-mindmap.esm.mjs';\nconsole.log({mindmap})\nawait mermaid.registerExternalDiagrams([mindmap]);\nmermaid.startOnLoad = false;\nObject.assign(window, {mermaid, mindmap});\nconsole.log('mermaid loaded')\nwindow.mermaidLoaded.state = true\nwindow.mermaidLoaded.resolve()",document.head.appendChild(script),console.log(script))},watch:{mermaidString:{immediate:!0,handler:(j=Object(c.a)(regeneratorRuntime.mark((function t(e){var element,n=this;return regeneratorRuntime.wrap((function(t){for(;;)switch(t.prev=t.next){case 0:if(this.chartRendered=!1,console.log("Creating mermaid chart for",e),this.mounted.state){t.next=7;break}return console.log("Waiting for the component to be mounted"),t.next=6,this.mounted.promise;case 6:console.log("Component mounted");case 7:if(window.mermaidLoaded.state){t.next=12;break}return console.log("Waiting for mermaid to be loaded"),t.next=11,window.mermaidLoaded.promise;case 11:console.log("Mermaid loaded");case 12:return element=document.getElementById("mermaid-container"),t.abrupt("return",this.$nextTick((function(){return console.log("Updating mermaid chart"),mermaid.renderAsync("mermaid-".concat(Date.now()),e,(function(svg){return element.innerHTML=svg,n.chartRendered=!0,console.log("Mermaid chart updated"),element.querySelectorAll("text").forEach((function(element){return element.style.cursor="pointer",element.addEventListener("click",(function(){var text;return text=(text=Array.from(element.querySelectorAll("tspan")).map((function(element){return element.textContent})).join(" ")).replace(/\s+/g," "),n.$emit("node-clicked",Object(x.a)(text))}))}))}))})));case 14:case"end":return t.stop()}}),t,this)}))),function(t){return j.apply(this,arguments)})},context:function(){if(!this.contextChanged)return this.contextChanged=!0,this.mixpanel.track("Context changed")}},methods:{helloWorld:function(){return console.log("Hello world")},validate:function(t){var i,e,n,c,l;if(!t)throw new r("Context is empty");if(n=t.split("\n"),0!==o(n[0]))throw new r("The first line must not be indented");if(0===o(n[1]))throw new r("The second line must be indented");for(l=o(n[1],1),i=e=2,c=n.length;2<=c?e<c:e>c;i=2<=c?++e:--e){if(o(n[i],l)>o(n[i-1],l)+1)throw new r("Line ".concat(i+1," is indented by more than one level more than the previous line"));if(o(n[i],l)<1)throw new r("Line ".concat(i+1," is not indented; only one root topic is allowed"))}return!0}}},S=O,T=(n(414),n(68)),component=Object(T.a)(S,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-col",[n("b-row",{staticClass:"justify-content-center",attrs:{id:"mermaid-container"}}),t.readonly?t._e():[t.isValid?t._e():n("b-alert",{staticClass:"text-left mt-3",attrs:{variant:"danger",show:""}},[n("strong",[t._v("Cannot render the mind map; please edit the context below:")]),n("ul",[n("li",[t._v("Exactly one line with no tabs in the beginning")]),n("li",[t._v("Every next line indented by the same, fewer, or just one more tab than the previous line")])])]),n("b-button",{staticClass:"btn-sm btn-light m-1",attrs:{variant:t.isValid?t.editInPlainText?"outline-success":"light":"outline-danger"},on:{click:function(e){t.editInPlainText=!t.editInPlainText,t.mixpanel.track("Switched plain text context editing "+(t.editInPlainText?"on":"off"))}}},[t._v("🖉")]),n("b-button",{staticClass:"btn-sm btn-light m-1",on:{click:function(e){return t.$emit("rebuild")}}},[t._v("↺")]),n("b-row",{directives:[{name:"show",rawName:"v-show",value:t.editInPlainText||!t.isValid,expression:"editInPlainText || !isValid"}],style:t.isValid?"":"border: 1px solid red; border-radius: 5px; padding: 10px;"},[n("EditSettings",{attrs:{title:"Edit context in plain text",value:{context:t.context},properties:{context:{type:"multiline",monospace:!0,label:"Mind map tree",placeholder:"Main topic\n\tSub-topic\n\t\tSub-sub-topic\n\tAnother sub-topic",description:"Tab/Shift-Tab to indent/unindent lines."}}},on:{input:function(e){t.context=e.context}}})],1)]],2)}),[],!1,null,"0a55d814",null);e.default=component.exports;installComponents(component,{EditSettings:n(403).default})}}]);