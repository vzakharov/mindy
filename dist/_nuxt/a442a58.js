(window.webpackJsonp=window.webpackJsonp||[]).push([[25,17],{397:function(t,e,n){"use strict";var o,r=n(0);n(15),n(24);o=function(t){return t},e.a=function(t){var e,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:{},d=n.deep,l=n.save,c=void 0===l?o:l,h=n.load,v=void 0===h?o:h;return{data:function(){var e;if(null==this.$options.propsData.value)throw new Error("Component ".concat(this.$options.name," requires a `value` prop. Make sure to use :value or v-model in the parent component to represent `").concat(t,"`."));return e={},Object(r.a)(e,t,null),Object(r.a)(e,"syncValue",{watchers:[]}),e},watch:(e={},Object(r.a)(e,t,{deep:d,handler:function(t){return this.$emit("input",c.call(this,t))}}),Object(r.a)(e,"value",{deep:d,immediate:!0,handler:function(e){return this[t]=v.call(this,e)}}),e)}}},455:function(t,e,n){"use strict";var o=n(394),r=n.n(o);e.a=function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:768;return{data:function(){return{narrow:!1,wide:!0,width:null}},mounted:function(){var e,n=this;return(e=function(){return n.width=window.innerWidth,n.narrow=n.width<t,n.wide=!n.narrow,console.log("Width changed to ".concat(n.width))})(),window.addEventListener("resize",r.a.debounce(e,100))}}}},456:function(t,e,n){var content=n(492);content.__esModule&&(content=content.default),"string"==typeof content&&(content=[[t.i,content,""]]),content.locals&&(t.exports=content.locals);(0,n(109).default)("7217f540",content,!0,{sourceMap:!1})},479:function(t,e,n){"use strict";n.r(e);var o=n(397),r={props:["value","secondaryPaneIcon","brand","tagline"],mixins:[Object(o.a)("show",{deep:!0})]},d=n(68),component=Object(d.a)(r,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",[n("nav",{staticClass:"navbar navbar-light bg-light justify-content-between align-items-center border-bottom"},[n("b-button",{staticClass:"btn-light btn-sm",attrs:{variant:t.show.sidebar?"outline-secondary":"light"},on:{click:function(e){t.show.sidebar=!t.show.sidebar}}},[n("span",{staticClass:"navbar-toggler-icon"})]),n("div",{staticClass:"lead d-inline pl-2",staticStyle:{"font-size":"1em"},attrs:{id:"mobile-brand"}},[n("strong",[t._v(t._s(t.brand)+"  ")]),t._v("· "+t._s(t.tagline))]),n("b-button",{staticClass:"d-md-none",attrs:{variant:t.show.secondaryPane?"outline-secondary":"light"},on:{click:function(e){t.show.secondaryPane=!t.show.secondaryPane}}},[n("b-icon",{staticClass:"text-muted",attrs:{icon:t.secondaryPaneIcon}})],1)],1)])}),[],!1,null,null,null);e.default=component.exports},491:function(t,e,n){"use strict";n(456)},492:function(t,e,n){var o=n(108)(!1);o.push([t.i,".vh-minus-navbar{height:calc(100vh - var(--navbar-height))}#sidebar{display:flex;flex-direction:column;position:fixed;top:0;left:0;bottom:0;width:var(--sidebar-width);z-index:20}#main{padding-left:calc(var(--sidebar-width));padding-right:0}@media (max-width:1200px){#sidebar{position:fixed;top:var(--navbar-height);left:0;bottom:0;box-shadow:0 10px 10px rgba(0,0,0,.2);width:var(--sidebar-width);z-index:20}#main{padding-left:0}}@media (max-width:768px){#secondary-pane{position:fixed;top:var(--navbar-height);left:auto;right:0;bottom:0;background-color:#fff;box-shadow:0 10px 10px rgba(0,0,0,.2);width:100%;max-width:90vw;z-index:10}}.slide-left-enter-active,.slide-left-leave-active,.slide-right-enter-active,.slide-right-leave-active{transition:transform .3s}.slide-left-enter,.slide-left-leave-to{transform:translateX(100%)}.slide-right-enter,.slide-right-leave-to{transform:translateX(-100%)}",""]),t.exports=o},536:function(t,e,n){"use strict";n.r(e);var o=n(455),r={props:["secondaryPaneIcon","brand","tagline","sidebarComponent","primaryPaneComponent","secondaryPaneComponent","resetLayout"],mixins:[Object(o.a)()],data:function(){return{show:{sidebar:!1,secondaryPane:!1},secondaryPaneCols:8}},watch:{resetLayout:function(t){if(t)return log("resetting layout"),this.show.sidebar=!1,this.show.secondaryPane=!1,this.$emit("update:resetLayout",!1)}}},d=(n(491),n(68)),component=Object(d.a)(r,(function(){var t=this,e=t.$createElement,n=t._self._c||e;return n("div",[n("style",[t._v(":root {\n  --navbar-height: "+t._s(t.width>1200?"0px":"55px")+";\n  --sidebar-width: 200px;\n  --sidebar-height: calc(100vh - var(--navbar-height));\n}")]),n("MobileNav",t._b({staticClass:"d-block d-xl-none",model:{value:t.show,callback:function(e){t.show=e},expression:"show"}},"MobileNav",{secondaryPaneIcon:t.secondaryPaneIcon,brand:t.brand,tagline:t.tagline},!1)),n("div",{staticClass:"vh-minus-navbar"},[n(t.width>1200?"div":"transition",{tag:"component",attrs:{name:"slide-right"}},[n("div",{directives:[{name:"show",rawName:"v-show",value:t.show.sidebar||t.width>1200,expression:"show.sidebar || width > 1200"}],staticClass:"vh-minus-navbar m-0 bg-light border-right justify-content-between overflow-auto",attrs:{id:"sidebar"}},[n("div",{staticClass:"p-2"},[n("div",{staticClass:"d-none d-xl-block text-center",staticStyle:{height:"56.4px"}},[n("h2",{staticClass:"mb-0 display-6",staticStyle:{"font-size":"1.2em"}},[t._v(t._s(t.brand))]),n("p",{staticClass:"lead",staticStyle:{"font-size":"1em"}},[t._v(t._s(t.tagline))])]),t._t("sidebar")],2),n("div",{staticClass:"border-top"},[t._t("sidebar-footer")],2)])]),n("div",{staticClass:"h-100 container-fluid",attrs:{id:"main"}},[n(t.wide?"my-multipane":"div",{tag:"component",staticClass:"p-0 h-100",attrs:{layout:"vertical"}},[n("div",{staticClass:"h-100 d-block",style:{width:t.wide?"400px":"100%","min-width":t.wide?"300px":"0px"}},[t._t("primary-pane")],2),n("div",{staticClass:"multipane-resizer"}),n("transition",{attrs:{name:"slide-left"}},[n("div",{directives:[{name:"show",rawName:"v-show",value:t.show.secondaryPane||t.wide,expression:"show.secondaryPane || wide"}],staticClass:"d-md-block border-left p-0 h-100",staticStyle:{"flex-grow":"1","min-width":"400px"},attrs:{id:"secondary-pane"}},[t._t("secondary-pane")],2)])],1)],1)],1)],1)}),[],!1,null,null,null);e.default=component.exports;installComponents(component,{MobileNav:n(479).default})}}]);