const baseUrl = process.env.BASE_URL ||
  'https://ideality.app/api/'
  // uncomment ^^ for production
  // 'http://localhost:3700/api/'
  // uncomment ^^ for development

export default {
  // Target: https://go.nuxtjs.dev/config-target
  target: 'static',
  ssr: false,
  router: {
    base: '/mindy/',
  },

  env: {
    NOTION_API_URL: process.env.NOTION_API_URL || 
      baseUrl + 'notion/',
  
    MINDY_API_URL: process.env.MINDY_API_URL ||
      baseUrl + 'mindy/',

    NOTION_MESSAGES_DB_ID: process.env.NOTION_MESSAGES_DB_ID ||
      'dec1a3932d774d97a1e549295b0dc302',

    POLYGON_TEMPLATES_DB_ID: process.env.POLYGON_TEMPLATES_DB_ID ||
      '485b3bd6b4524c1dbd9ef2acc5bccfbf',

    POLYGON_UPVOTES_DB_ID: process.env.POLYGON_UPVOTES_DB_ID ||
      'ecdca719f95b4eeab4c86118e44d162c',

    POLYGON_API_URL: process.env.POLYGON_API_URL ||
      baseUrl + 'polygon/',

    MIXPANEL_TOKEN: process.env.MIXPANEL_TOKEN ||
      'f9ed5012981005142ed33251c919eb41',

    MIXPANEL_DEBUG: process.env.MIXPANEL_DEBUG ||
      true,
  },


  // Global page headers: https://go.nuxtjs.dev/config-head
  head: {
    title: 'Mindy · Brainstorm with AI',
    htmlAttrs: {
      lang: 'en'
    },
    meta: [
      { charset: 'utf-8' },
      { name: 'viewport', content: 'width=device-width, initial-scale=1' },
      { hid: 'description', name: 'description', content: '' },
      { name: 'format-detection', content: 'telephone=no' }
    ],
    link: [
      { rel: 'icon', type: 'image/x-icon', href: './favicon.png' }
    ]
  },

  // Global CSS: https://go.nuxtjs.dev/config-css
  css: [
  ],

  // Plugins to run before rendering page: https://go.nuxtjs.dev/config-plugins
  plugins: [
  ],

  // Auto import components: https://go.nuxtjs.dev/config-components
  components: true,

  // Modules for dev and build (recommended): https://go.nuxtjs.dev/config-modules
  buildModules: [
  ],

  // Modules: https://go.nuxtjs.dev/config-modules
  modules: [
    // https://go.nuxtjs.dev/bootstrap
    ['bootstrap-vue/nuxt', { icons: true }],
    // https://go.nuxtjs.dev/axios
    '@nuxtjs/axios',
    'nuxt-coffeescript-module',
    '@nuxtjs/markdownit',
    // 'nuxt-mermaid-string',
  ],
  
  markdownit: {
    runtime: true // Support `$md()`
  },

  // Axios module configuration: https://go.nuxtjs.dev/config-axios
  axios: {
    // Workaround to avoid enforcing hard-coded localhost:3000: https://github.com/nuxt-community/axios-module/issues/308
    baseURL: '/',
  },

  // Build Configuration: https://go.nuxtjs.dev/config-build
  build: {

    extend(config) {
      config.module.rules.push({
        test: /\.mjs$/,
        include: /node_modules/,
        type: 'javascript/auto',
      })
    },
    
  },

  server: {
    port: process.env.PORT || 1250,
  },
}
