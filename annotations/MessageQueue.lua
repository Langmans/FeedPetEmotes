---@meta
-- Editor-only types for the MessageQueue addon (LenweSaralonde/MessageQueue),
-- an optional dependency used by Sender.lua. Not listed in the .toc, so the
-- game never loads this file. Only what Sender.lua calls is declared.

---@class MessageQueue
MessageQueue = {}

---Queues a function that needs a hardware event; MessageQueue runs it on the
---player's next input. The function may do one such action only.
---@param f fun()
function MessageQueue.Enqueue(f) end
