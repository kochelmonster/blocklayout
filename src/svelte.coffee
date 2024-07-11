import { convert } from "./convert.js";

export default blocklayout = () ->
    return
        markup: ({content}) ->
            result = convert(content)
            return {code: result.result} if result.converted
