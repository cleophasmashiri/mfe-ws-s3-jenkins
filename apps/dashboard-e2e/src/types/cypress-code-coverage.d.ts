declare module '@cypress/code-coverage/use-browserify-istanbul' {
    import { ConfigOptions } from '@cypress/code-coverage';
    export default function (on: any, config: ConfigOptions): ConfigOptions;
}
