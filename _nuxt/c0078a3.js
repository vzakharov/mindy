(window.webpackJsonp=window.webpackJsonp||[]).push([[8,9],{395:function(t,e,n){"use strict";var r,o=n(0);n(15),n(24);r=function(t){return t},e.a=function(t){var e,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},l=n.deep,c=n.save,d=void 0===c?r:c,h=n.load,f=void 0===h?r:h;return{data:function(){var e;if(null==this.$options.propsData.value)throw new Error("Component ".concat(this.$options.name," requires a `value` prop. Make sure to use :value or v-model in the parent component to represent `").concat(t,"`."));return e={},Object(o.a)(e,t,null),Object(o.a)(e,"syncValue",{watchers:[]}),e},watch:(e={},Object(o.a)(e,t,{deep:l,handler:function(t){return this.$emit("input",d.call(this,t))}}),Object(o.a)(e,"value",{deep:l,immediate:!0,handler:function(e){return this[t]=f.call(this,e)}}),e)}}},415:function(t,e,n){"use strict";n.r(e);var r,o=n(40),l=(n(248),n(15),n(19),n(1),n(38),n(4),n(63),n(11),n(30),n(22),n(395));r=function(t){return"number"===this.inputProps.type?Number(t):t};var c={mixins:[Object(l.a)("setting",{save:r,load:r})],props:{value:{required:!0},properties:{type:Object,default:function(){return{}}}},computed:{id:function(){return"edit-settings-input-".concat(this.$vnode.key,"-").concat(Math.random().toString(36).slice(2))},label:function(){return this.properties.label||this.$vnode.key},description:function(){var t;return t=this.properties.description,(null!=t?t[!0]:void 0)&&t[!1]?t[this.setting]:t},inputTagAndProps:function(){var t,e,n=this;if(e={multiline:function(){var t;return{tag:"b-textarea",props:{rows:Math.max(10,Math.min(20,null!=(t=n.value)?t.split("\n").length:void 0)),style:n.properties.monospace?"font-family: monospace; tab-size: 2; -moz-tab-size: 2;":"",placeholder:n.properties.placeholder||"Enter text here"}}},text:{tag:"b-input",props:{type:"text",placeholder:this.properties.placeholder||"Enter text here"}},number:{tag:"b-input",props:{type:"number",placeholder:this.properties.placeholder||"Enter a number here"}},boolean:{tag:"b-checkbox",props:{switch:!0}}},this.properties.type)return("function"==typeof(t=e[this.properties.type])?t():void 0)||t;switch(Object(o.a)(this.value)){case"number":return e.number;case"boolean":return e.boolean;default:return e.text}},inputTag:function(){return this.inputTagAndProps.tag},inputProps:function(){return this.inputTagAndProps.props}},methods:{onTab:function(t){var e,n,r,o,l,c,d=this;if(this.properties.monospace){var h=this.$refs.input.$el;return o=h.selectionStart,r=h.selectionEnd,c=this.value.substring(0,o),n=this.value.substring(o,r),l=this.value.substring(r),e=c.lastIndexOf("\n")||0,n=c.substring(e+1,o)+n,c=c.substring(0,e+1),n=n.replace(/(\n|^)(\t?)/g,t.shiftKey?"$1":"$1$2\t"),this.setting=c+n+l,t.preventDefault(),this.$nextTick((function(){return d.$refs.input.$el.setSelectionRange(o+(t.shiftKey?-1:1),r+(t.shiftKey?-1:1))}))}}}},d=n(68),component=Object(d.a)(c,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-form-group",t._b({attrs:{"label-for":t.id}},"b-form-group",{label:t.label,description:t.description},!1),[n(t.inputTag,t._b({ref:"input",tag:"component",attrs:{id:t.id},on:{keydown:function(e){return!e.type.indexOf("key")&&t._k(e.keyCode,"tab",9,e.key,"Tab")?null:t.onTab.apply(null,arguments)}},model:{value:t.setting,callback:function(e){t.setting=e},expression:"setting"}},"component",t.inputProps,!1))],1)}),[],!1,null,null,null);e.default=component.exports},434:function(t,e,n){"use strict";n.r(e);var r=n(395),o={mixins:[Object(r.a)("settings",{deep:!0})],props:{title:{type:String,default:"Edit settings"},okTitle:{type:String,default:"Save"},cancelTitle:{type:String,default:"Cancel"},value:{type:Object,required:!0},properties:{type:Object,default:function(){return{}}}}},l=n(68),component=Object(l.a)(o,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("b-form",{staticStyle:{width:"100%"}},t._l(t.settings,(function(e,r){return n("EditSettingsInput",{key:r,attrs:{properties:t.properties[r]},model:{value:t.settings[r],callback:function(e){t.$set(t.settings,r,e)},expression:"settings[key]"}})})),1)}),[],!1,null,null,null);e.default=component.exports;installComponents(component,{EditSettingsInput:n(415).default})}}]);